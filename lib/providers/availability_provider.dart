import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/station.dart';
import '../models/availability.dart';
import '../services/local_data_service.dart';
import '../utils/constants.dart'; // Make sure this file exists

class AvailabilityProvider with ChangeNotifier {
  final LocalDataService _localDataService = LocalDataService();

  Station? _fromStation;
  Station? _toStation;
  DateTime _selectedDate = DateTime.now();
  List<TrainAvailability> _trains = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Station? get fromStation => _fromStation;
  Station? get toStation => _toStation;
  DateTime get selectedDate => _selectedDate;
  List<TrainAvailability> get trains => _trains;
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

  /// Service passthrough for Autocomplete widget
  Future<List<Station>> searchStations(String query) {
    return _localDataService.searchStations(query);
  }

  // This replaces 'get-aval' click logic
  Future<void> fetchAvailability() async {
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
      // Format date as DD-MM-YYYY
      final String doj = DateFormat('dd-MM-yyyy').format(_selectedDate);
      
      // THIS IS THE NEW, WORKING API URL FROM YOUR NETWORK LOG
      final url = Uri.parse(
          '${KApi.confirmTktBaseUrl}/api/v1/trains/search?sourceStationCode=${_fromStation!.code}&destinationStationCode=${_toStation!.code}&dateOfJourney=$doj&addAvailabilityCache=true&enableNearby=true&enableTG=true');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // THIS IS THE NEW PARSING LOGIC
        if (data['data'] != null && data['data']['trainList'] != null) {
          
          var trainListJson = data['data']['trainList'] as List;
          
          _trains = trainListJson
              .map((trainJson) => TrainAvailability.fromJson(trainJson))
              .toList();
        }

        if (_trains.isEmpty) {
          _error = "No trains found for this route on this date.";
        }
      } else {
        _error = "Failed to fetch availability: ${response.statusCode}";
      }
    } catch (e) {
      _error = "An error occurred: $e";
    }

    _isLoading = false;
    notifyListeners();
  }
}