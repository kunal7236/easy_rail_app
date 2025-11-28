import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/station_arrival.dart';
import '../utils/constants.dart'; 

class AtStationProvider with ChangeNotifier {
  List<StationArrival> _trains = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<StationArrival> get trains => _trains;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // This replaces your 'searchStation' function
  Future<void> fetchTrainsAtStation(String stationCode) async {
    if (stationCode.isEmpty) {
      _error = "Please enter a station code.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _trains = [];
    notifyListeners();

    try {
      // 1. Correct URL Path
      final url = Uri.parse('${KApi.easyRailBackendUrl}/at-station');

      // 2. Create Request Body using 'stnCode'
      final body = jsonEncode({
        'stnCode': stationCode,
      });

      debugPrint("At Station Provider: Calling POST $url with body: $body"); // Log

      // 3. Use http.post
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', 
        },
        body: body,
      );

      debugPrint("At Station Provider: Response Status: ${response.statusCode}"); // Log

      if (response.statusCode == 200) {
        // 4. Parse the response (which is directly a List)
        final List<dynamic> data = json.decode(response.body);
        _trains = data.map((json) => StationArrival.fromJson(json)).toList();

        if (_trains.isEmpty) {
          _error = "No trains found for station code '$stationCode'.";
        }
      } else {
        debugPrint("At Station Provider: Error Body: ${response.body}"); // Log error body
        _error = "Failed to fetch data: ${response.statusCode}";
      }
    } catch (e) {
      _error = "An error occurred: $e";
      debugPrint("At Station Provider: Catch Error: $_error"); // Log exceptions
    }

    _isLoading = false;
    notifyListeners();
  }
}