import 'dart:async';
import 'dart:convert'; // Needed for jsonEncode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/live_status.dart'; // Uses the updated model
import '../utils/constants.dart';

class LiveStatusProvider with ChangeNotifier {
  // --- UPDATED STATE ---
  List<LiveStationStatus> _stations = []; // Changed from LiveStatus?
  bool _isLoading = false;
  String? _error;
  Timer? _timer;
  int _currentStationIndex = -1;

  // Stored parameters for auto-refresh
  String? _currentTrainNo;
  DateTime? _currentDate;

  // --- UPDATED GETTERS ---
  List<LiveStationStatus> get stations => _stations; // Changed getter
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentStationIndex => _currentStationIndex;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void clearStatus() {
    _cancelTimer();
    _stations = []; // Clear the list
    _error = null;
    _isLoading = false;
    _currentTrainNo = null;
    _currentDate = null;
    _currentStationIndex = -1;
    notifyListeners();
  }

  Future<void> fetchLiveStatus(String trainNo, DateTime date) async {
    _cancelTimer();
    _stations = []; // Clear the list
    _error = null;
    _isLoading = true;
    _currentTrainNo = trainNo;
    _currentDate = date;
    notifyListeners();

    await _fetchData();
  }

  // --- UPDATED API CALL LOGIC ---
  Future<void> _fetchData() async {
    if (_currentTrainNo == null || _currentDate == null) return;

    // Set loading only for the first fetch
    if (_stations.isEmpty) { // Check if list is empty
      _isLoading = true;
      notifyListeners();
    }

    try {
      final String dateStr = DateFormat('yyyy-MM-dd').format(_currentDate!);

      // 1. Correct URL Path
      final url = Uri.parse('${KApi.easyRailBackendUrl}/fetch-train-status');

      // 2. Create Request Body
      final body = jsonEncode({
        'trainNumber': _currentTrainNo, // MUST be 'trainNumber'
        'dates': dateStr,             // MUST be 'dates'
      });

      debugPrint("Live Status Provider: Calling POST $url with body: $body"); // Log

      // 3. Use http.post
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Important for POST
        },
        body: body,
      );

      debugPrint("Live Status Provider: Response Status: ${response.statusCode}"); // Log

      if (response.statusCode == 200) {
        // 4. Parse the response (which is directly a List)
        final List<dynamic> data = json.decode(response.body);
        _stations = data.map((s) => LiveStationStatus.fromJson(s)).toList();

        // Find the index of the "current" station
        _currentStationIndex = _stations.indexWhere((s) => s.isCurrent);
        if (_currentStationIndex == -1) {
           // Fallback: find the first "upcoming" if no "current"
           _currentStationIndex = _stations.indexWhere((s) => s.status.toLowerCase() == 'upcoming');
           if (_currentStationIndex == -1) _currentStationIndex = 0; // Default to top
        }

        _error = null;
      } else {
        debugPrint("Live Status Provider: Error Body: ${response.body}"); // Log error body
        _error = "Failed to fetch status: ${response.statusCode}";
      }
    } catch (e) {
      _error = "An error occurred: $e";
      debugPrint("Live Status Provider: Catch Error: $_error"); // Log exceptions
    }

    _isLoading = false;
    notifyListeners();
    _startTimer(); // Restart timer after fetch
  }

  void _startTimer() {
    _cancelTimer();
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      debugPrint("Refreshing live status...");
      _fetchData();
    });
  }
}