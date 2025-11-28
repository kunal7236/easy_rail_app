import 'package:flutter/material.dart';

class SeatAvailability {
  final String className;
  final int totalFare;
  final String availabilityStatus;
  final String prediction;
  final String quota;

  SeatAvailability({
    required this.className,
    required this.totalFare,
    required this.availabilityStatus,
    required this.prediction,
    required this.quota,
  });

  // New factory to parse the nested cache objects
  factory SeatAvailability.fromCache(Map<String, dynamic> json, String quotaName) {
    return SeatAvailability(
      // 'travelClass' is the key in the JSON
      className: json['travelClass'] as String? ?? '??',
      
      // 'fare' is a String in the JSON, so we must parse it
      totalFare: int.tryParse(json['fare'] ?? '0') ?? 0,
      
      // 'availabilityDisplayName' is the key
      availabilityStatus: json['availabilityDisplayName'] as String? ?? 'N/A',
      
      // 'predictionDisplayName' is the key
      prediction: json['predictionDisplayName'] as String? ?? '',
      
      // We pass in 'GN' or 'TQ'
      quota: quotaName, 
    );
  }

  // --- The rest of this code (for styling) is unchanged ---

  Color get statusColor {
    String status = availabilityStatus.toLowerCase();
    if (status.contains('not available') || status.contains('waitlisted')) {
      return const Color(0xFFd74f4f); // Red
    }
    else if (status.contains('available') || status.contains('avl')) {
      return const Color(0xFF10b94b); // Green
    }

    return Colors.orange; // RAC/etc.
  }

  Color get backgroundColor {
    String status = availabilityStatus.toLowerCase();
    if (status.contains('not available') || status.contains('waitlisted')) {
      return const Color(0xFFFBF2F2); // Light Red
    }
    else if (status.contains('available') || status.contains('avl')) {
      return const Color(0xFFd4fad1); // Light Green
    }

    return const Color(0xFFFFFBEA); // Light Orange
  }
}

// ##################################################################
// ##  NEW TrainAvailability MODEL
// ##  Parses a single train from the 'trainList'
// ##################################################################
class TrainAvailability {
  final String trainNumber;
  final String trainName;
  final String departureTime;
  final String arrivalTime;
  final String duration; // Now a formatted string (e.g., "3h 23m")
  final String fromStnCode;
  final String toStnCode;
  final bool pantry;
  final List<SeatAvailability> availabilityList;

  TrainAvailability({
    required this.trainNumber,
    required this.trainName,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.fromStnCode,
    required this.toStnCode,
    required this.pantry,
    required this.availabilityList,
  });

  // New factory to parse the main 'trainList' object
  factory TrainAvailability.fromJson(Map<String, dynamic> json) {
    
    // --- Helper to parse the duration ---
    // The JSON provides 'duration' as minutes (e.g., 203)
    int durationInMinutes = json['duration'] as int? ?? 0;
    String formattedDuration = 
        "${(durationInMinutes / 60).floor()}h ${durationInMinutes % 60}m";

    // --- Helper to build the list of seats ---
    List<SeatAvailability> seats = [];

    // 1. Add all "General" (GN) quota seats
    if (json['availabilityCache'] is Map) {
      (json['availabilityCache'] as Map<String, dynamic>).forEach((key, value) {
        if (value is Map<String, dynamic>) {
          seats.add(SeatAvailability.fromCache(value, 'GN'));
        }
      });
    }

    // 2. Add all "Tatkal" (TQ) quota seats
    if (json['availabilityCacheTatkal'] is Map) {
      (json['availabilityCacheTatkal'] as Map<String, dynamic>).forEach((key, value) {
        if (value is Map<String, dynamic>) {
          seats.add(SeatAvailability.fromCache(value, 'TQ'));
        }
      });
    }

    // --- Return the final object ---
    return TrainAvailability(
      trainNumber: json['trainNumber'] as String? ?? 'N/A',
      trainName: json['trainName'] as String? ?? 'Unknown',
      departureTime: json['departureTime'] as String? ?? '--',
      arrivalTime: json['arrivalTime'] as String? ?? '--',
      duration: formattedDuration, // Use the formatted string
      fromStnCode: json['fromStnCode'] as String? ?? 'N/A',
      toStnCode: json['toStnCode'] as String? ?? 'N/A',
      pantry: json['hasPantry'] as bool? ?? false,
      availabilityList: seats, // Use the list we just built
    );
  }
}