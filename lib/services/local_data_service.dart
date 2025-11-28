import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/station.dart';
import '../models/train_suggestion.dart'; 

class LocalDataService {
  List<Station> _stations = [];
  List<TrainSuggestion> _trains = []; 

  Future<void> loadStations() async {
    if (_stations.isNotEmpty) return;
    try {
      final String response = await rootBundle.loadString('assets/json/stations.json');
      
      // 1. Decode as a Map (Object)
      final Map<String, dynamic> data = json.decode(response);
      
      // 2. Access the list inside the map (assuming the key is 'stations')
      final List<dynamic> stationList = data['stations'];
      
      // 3. Map the list
      _stations = stationList.map((json) => Station.fromJson(json)).toList();
      
    } catch (e) {
      debugPrint("Error loading stations: $e");
    }
  }

  Future<List<Station>> searchStations(String query) async {
    if (_stations.isEmpty) {
      await loadStations();
    }
    
    if (query.isEmpty) {
      return [];
    }
    
    return _stations
        .where((station) =>
            station.name.toLowerCase().contains(query.toLowerCase()) ||
            station.code.toLowerCase().contains(query.toLowerCase()))
        .take(10) 
        .toList();
  }


  Future<void> loadTrains() async {
  if (_trains.isNotEmpty) return;
      try {
        final String response = await rootBundle.loadString('assets/json/trains.json');
        
        // 1. Decode as a List, since  file is a List
        final List<dynamic> data = json.decode(response);
        
        // 2. Map the list directly
        _trains = data.map((json) => TrainSuggestion.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error loading trains: $e");
    }
  }

  Future<List<TrainSuggestion>> searchTrains(String query) async {
    if (_trains.isEmpty) {
      await loadTrains();
    }
    
    if (query.isEmpty) {
      return [];
    }
    
    return _trains
        .where((train) =>
            train.name.toLowerCase().contains(query.toLowerCase()) ||
            train.number.contains(query))
        .take(10) 
        .toList();
  }
}