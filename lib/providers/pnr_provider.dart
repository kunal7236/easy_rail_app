import 'dart:convert'; // Make sure this is imported
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Make sure this is imported
import 'package:http/http.dart' as http; // Make sure this is imported
import '../models/pnr_status.dart'; // Make sure this path is correct

class PnrProvider with ChangeNotifier {
  // --- Class Properties (Define only ONCE) ---
  PnrData? _pnrData; // Use the correct model
  bool _isLoading = false;
  String? _error;

  // --- Getters (Define only ONCE) ---
  PnrData? get pnrData => _pnrData; // Use the correct getter name
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- fetchPnrStatus Function (Define only ONCE) ---
  Future<void> fetchPnrStatus(String pnrNumber) async {
    if (pnrNumber.length != 10) {
      _error = "Please enter a valid 10-digit PNR number.";
      notifyListeners();
      return;
    }

    // Update class properties
    _isLoading = true;
    _error = null;
    _pnrData = null; // Clear previous results
    notifyListeners();

    try {
      final url = Uri.parse('https://irctc-indian-railway-pnr-status.p.rapidapi.com/getPNRStatus/$pnrNumber');
      final apiKey = dotenv.env['RAPID_API_KEY'];

      debugPrint("PNR Provider: Using API Key: $apiKey");

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found or is empty in .env');
      }

      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': 'irctc-indian-railway-pnr-status.p.rapidapi.com',
        'Origin': 'https://easy-rail.onrender.com',
        'Referer': 'https://easy-rail.onrender.com/',
      });

      debugPrint("PNR Provider: Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final pnrResponse = PnrStatusResponse.fromJson(data); // Use the wrapper model

        if (pnrResponse.success && pnrResponse.data != null) {
          _pnrData = pnrResponse.data; // Store the inner PnrData object
        } else {
          _error = data['errorMessage'] as String? ?? 'API returned success=false or null data.';
        }
      } else {
        debugPrint("PNR Provider: Error Response Body: ${response.body}");
        _error = 'Error fetching PNR: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      debugPrint("PNR Provider: Catch block error: $_error");
    }

    // Update class properties
    _isLoading = false;
    notifyListeners();
  }
}