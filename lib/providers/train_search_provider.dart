import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/train_suggestion.dart';
import '../services/local_data_service.dart';
import '../services/erail_parser.dart';
import '../utils/constants.dart';
import '../models/train_details.dart';
import '../models/train_route.dart';

class TrainSearchProvider with ChangeNotifier {
  final LocalDataService _localDataService = LocalDataService();

  TrainSuggestion? _selectedTrain;
  TrainDetails? _trainDetails;
  List<TrainRoute> _trainRoute = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  TrainDetails? get trainDetails => _trainDetails;
  List<TrainRoute> get trainRoute => _trainRoute;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setSelectedTrain(TrainSuggestion? train) {
    _selectedTrain = train;
  }



  /// Service passthrough for Autocomplete widget
  Future<List<TrainSuggestion>> searchTrains(String query) {
    return _localDataService.searchTrains(query);
  }

  Future<void> fetchTrainDetails() async {
    if (_selectedTrain == null) {
      _error = "Please select a train from the suggestions.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _trainDetails = null;
    _trainRoute = [];
    notifyListeners();

    try {
      // --- Step 1: Get Train Details ---
      final detailsUrl = Uri.parse(
        '${KApi.eRailBaseUrl}/getTrains.aspx?TrainNo=${_selectedTrain!.number}&DataSource=0&Language=0&Cache=true',
      );
      debugPrint("Provider: Calling details URL: $detailsUrl");
      final detailsResponse = await http.get(detailsUrl);
      debugPrint(
        "Provider: Details response status: ${detailsResponse.statusCode}",
      );

      if (detailsResponse.statusCode == 200) {
        // Decode explicitly using UTF-8 for safety
        String detailsBody = utf8.decode(detailsResponse.bodyBytes);
        _trainDetails = ErailParser.parseTrainDetails(detailsBody);

        if (_trainDetails == null) {
          throw Exception(
            'Failed to parse train details. Parser returned null.',
          );
        }

        notifyListeners(); // Show basic details

        // --- Step 2: Get Train Route ---
        final routeUrl = Uri.parse(
          '${KApi.eRailBaseRoot}/data.aspx?Action=TRAINROUTE&Password=2012&Data1=${_trainDetails!.trainId}&Data2=0&Cache=true',
        );
        debugPrint("Provider: Calling route URL: $routeUrl");
        final routeResponse = await http.get(routeUrl);
        debugPrint(
          "Provider: Route response status: ${routeResponse.statusCode}",
        );

        if (routeResponse.statusCode == 200) {
          // --- FORCE UTF-8 DECODING HERE ---
          String rawResponseBody = utf8.decode(routeResponse.bodyBytes);
          debugPrint(
            "Provider: Route response body length (UTF-8): ${rawResponseBody.length}",
          );
          // --- END FIX ---

          _trainRoute = ErailParser.parseTrainRoute(rawResponseBody);

          if (_trainRoute.isEmpty) {
            debugPrint(
              "Provider Error: Route parser returned empty list. Raw Body (UTF-8) was: $rawResponseBody",
            );
            throw Exception('Route parser returned an empty list.');
          }
        } else {
          throw Exception(
            'Failed to fetch train route. Status: ${routeResponse.statusCode}',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch train details. Status: ${detailsResponse.statusCode}',
        );
      }
    } catch (e) {
      _error = "An error occurred: $e";
      debugPrint("Provider Error: $_error");
    }

    _isLoading = false;
    notifyListeners();
  }
}
