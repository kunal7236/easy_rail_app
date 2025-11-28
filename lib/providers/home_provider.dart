import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/station.dart';
import '../models/train.dart';
import '../services/erail_parser.dart';
import '../services/local_data_service.dart';
import '../utils/constants.dart'; // Make sure this file exists

class HomeProvider with ChangeNotifier {
  final LocalDataService _localDataService = LocalDataService();

  Station? _fromStation;
  Station? _toStation;
  DateTime _selectedDate = DateTime.now();
  List<Train> _trains = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Station? get fromStation => _fromStation;
  Station? get toStation => _toStation;
  DateTime get selectedDate => _selectedDate;
  List<Train> get trains => _trains;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Setters
  void setFromStation(Station? station) {
    _fromStation = station;
    notifyListeners();
  }

  void setToStation(Station? station) {
    _toStation = station;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void swapStations() {
    final temp = _fromStation;
    _fromStation = _toStation;
    _toStation = temp;
    notifyListeners();
  }

  /// Service passthrough for Autocomplete widget
  Future<List<Station>> searchStations(String query) {
    return _localDataService.searchStations(query);
  }

  /// This replaces 'main-search' click logic

  Future<void> searchTrains() async {
    if (_fromStation == null || _toStation == null) {
      _error = "Please select 'From' and 'To' stations.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _trains = [];
    notifyListeners();

    try {
      final url = Uri.parse(
          '${KApi.eRailBaseUrl}/getTrains.aspx?Station_From=${_fromStation!.code}&Station_To=${_toStation!.code}&DataSource=0&Language=0&Cache=true');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        
        List<Train> allTrains = ErailParser.parseTrainsBetweenStations(response.body);

        // --- BUG 2 FIX: Corrected Date Filtering Logic ---
        
        // _selectedDate.weekday: Monday=1, Tuesday=2, ..., Sunday=7
        // We need an index where Monday=0, Tuesday=1, ..., Sunday=6
        // This maps perfectly to the API's "1000000" (Mon-Sun) format.
        int erailDayIndex = _selectedDate.weekday - 1; 

        _trains = allTrains.where((train) {
          // Check if list is valid and index is in bounds
          if (train.runningDays.length < 7 || erailDayIndex >= train.runningDays.length) {
            return false;
          }
          // Check if the train runs on that day ('Y' or 'N')
          return train.runningDays[erailDayIndex] == 'Y';
        }).toList();
        // --- END OF CORRECTION ---

        if (_trains.isEmpty) {
          _error = "No trains found running on ${DateFormat('yyyy-MM-dd').format(_selectedDate)}.";
        }
      } else {
        _error = "Failed to fetch trains: ${response.statusCode}";
      }
    } catch (e) {
      _error = "An error occurred: $e";
    }

    _isLoading = false;
    notifyListeners();
  }
}