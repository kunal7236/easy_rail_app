import 'package:flutter/foundation.dart';

import '../models/train.dart';
import '../models/train_details.dart';
import '../models/train_route.dart';

class ErailParser {

  static TrainDetails? parseTrainDetails(String data) {
    try {
      // 1. Split by '~~~~~~~~'
      final mainParts = data.split('~~~~~~~~');
      if (mainParts.length < 2) {
        debugPrint("Parser Error: Could not split response by '~~~~~~~~'.");
        return null;
      }

      // 2. Parse the first part (detailsParts corresponds to JS data1)
      List<String> detailsParts = mainParts[0].split('~');
      int startIndexDetails = detailsParts.indexWhere(
        (el) => el.isNotEmpty && el.contains(RegExp(r'^\^?\d{5}$')),
      );
      if (startIndexDetails == -1) {
        startIndexDetails = detailsParts.indexWhere((el) => el.startsWith('^'));
        if (startIndexDetails == -1) {
          debugPrint(
            "Parser Error: Could not find starting point in details section.",
          );
          return null;
        }
      }
      List<String> finalDetailsParts = detailsParts.sublist(startIndexDetails);
      debugPrint(
        "Parser: Found ${finalDetailsParts.length} parts in final details section.",
      );

      // 3. Parse the second part (idParts corresponds to JS data2) for train_id
      List<String> idParts = mainParts[1]
          .split('~')
          .where((el) => el.isNotEmpty)
          .toList();
      debugPrint(
        "Parser: Found ${idParts.length} parts in ID section (part 1).",
      );
      if (idParts.length < 13) {
        debugPrint(
          "Parser Error: Not enough parts in ID section. Expected >= 13, got ${idParts.length}",
        );
        return null;
      }
      String trainId = idParts[12]; 
      debugPrint("Parser: Extracted trainId: $trainId");
      if (int.tryParse(trainId) == null) {
        debugPrint(
          "Parser Error: Extracted trainId '$trainId' is not a valid number.",
        );
        return null;
      }

      String safeGet(
        List<String> list,
        int index, [
        String defaultValue = 'N/A',
      ]) {
        return index >= 0 && index < list.length ? list[index] : defaultValue;
      }
   
      return TrainDetails(
        trainNo: safeGet(finalDetailsParts, 0).replaceFirst('^', ''),
        trainName: safeGet(finalDetailsParts, 1),
        sourceName: safeGet(finalDetailsParts, 2),
        sourceCode: safeGet(finalDetailsParts, 3),
        destName: safeGet(finalDetailsParts, 4),
        destCode: safeGet(finalDetailsParts, 5),
        trainId: trainId,
        departureTime: safeGet(finalDetailsParts, 10).replaceAll('.', ':'),
        arrivalTime: safeGet(finalDetailsParts, 11).replaceAll('.', ':'),
        travelTime:
            "${safeGet(finalDetailsParts, 12).replaceAll('.', ':')} hrs",
        runningDays: safeGet(
          finalDetailsParts,
          13,
          '0000000',
        ), // Default to '0000000' if missing
      );
    } catch (e) {
      debugPrint("Error parsing train details: $e");
      return null;
    }
  }

  static List<Train> parseTrainsBetweenStations(String data) {
    final List<Train> trains = [];
    try {

      final actualData = data.split('^');
      if (actualData.length < 2) return []; // No train data

      final trainLines = actualData.sublist(1);

      for (final line in trainLines) {
        final parts = line.split('~');

        if (parts.length > 13) {

          String runningDaysString = parts[13]; // e.g., "1000000"

          List<String> runningDaysList = runningDaysString.split('').map((day) {
            return day == '1' ? 'Y' : 'N';
          }).toList();

          List<String> classes = [];
          if (parts.length > 30) {
            String classData = parts[31];
            RegExp exp = RegExp(r'([1-3]A|SL|2S|CC|EC)');
            Iterable<Match> matches = exp.allMatches(classData);
            classes = matches.map((m) => m[0]!).toSet().toList();
          }

          trains.add(
            Train(
              trainNo: parts[0],
              trainName: parts[1],
              source: parts[2], // Overall Source
              destination: parts[4], // Overall Destination
              departureTime: parts[10], // Departure from *searched* station
              arrivalTime: parts[11], // Arrival at *searched* station
              travelTime: parts[12], // Travel time between *searched* stations
              runningDays: runningDaysList, // The new List<String>
              classes: classes,
            ),
          );
        }
      }
      return trains;
    } catch (e) {
      debugPrint("Error parsing trains between stations: $e");
      return [];
    }
  }


  static List<TrainRoute> parseTrainRoute(String data) {
    final List<TrainRoute> route = [];
    try {

      // Find the index of the first '#'
      int hashIndex = data.indexOf('#');
      if (hashIndex == -1) {
        debugPrint("Route Parser Error: No '#' found in the response.");
        return [];
      }

      int caretIndex = data.indexOf('^', hashIndex);
      if (caretIndex == -1) {
        debugPrint("Route Parser Error: No '^' found after the first '#'.");
        return [];
      }

      // Get the substring containing ALL route data (from the first '^' to the end)
      String routeDataString = data.substring(caretIndex).trim();
      debugPrint(
        "Route Parser: Extracted route data string. Length: ${routeDataString.length}",
      );

      final stationLines = routeDataString.split(RegExp(r'\s*\^\s*'));

      debugPrint(
        "Route Parser: Found ${stationLines.length} potential station segments after RegExp split.",
      );

      for (final line in stationLines) {
        if (line.isEmpty) {
          continue; 
        }
        final stationParts = line.split('~');

        // Remove the leading number (e.g., "1", "2") if present
        if (stationParts.isNotEmpty && int.tryParse(stationParts[0]) != null) {
          stationParts.removeAt(0);
        } else {
          debugPrint(
            "Route Parser Warning: Line segment doesn't start with a number: $line",
          );
          continue;
        }

        // Indices after removing number: Code[0], Name[1], Arr[2], Dep[3], ?, Dist[5]
        if (stationParts.length > 5) {
          route.add(
            TrainRoute(
              stationCode: stationParts[0],
              stationName: stationParts[1],
              arrivalTime: stationParts[2],
              departureTime: stationParts[3],
              distance: stationParts[5],
            ),
          );
        } else {
          debugPrint(
            "Route Parser Warning: Skipping line with insufficient parts (${stationParts.length}) after removing number: $line",
          );
        }
      }

      if (route.isEmpty && stationLines.length > 1) {
        debugPrint(
          "Route Parser Error: Parsed 0 stations even though RegExp split found segments.",
        );
      } else {
        debugPrint(
          "Route Parser: Successfully parsed ${route.length} stations.",
        );
      }

      return route;
    } catch (e) {
      debugPrint("Error parsing train route: $e");
      return [];
    }
  }
}
