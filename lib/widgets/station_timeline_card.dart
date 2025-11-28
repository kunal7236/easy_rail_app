import 'package:flutter/material.dart';
import '../models/live_status.dart';
import '../utils/app_theme.dart';

class StationTimelineCard extends StatelessWidget {
  final LiveStationStatus stationStatus;
  final bool isFirst;
  final bool isLast;

  const StationTimelineCard({
    super.key,
    required this.stationStatus,
    this.isFirst = false,
    this.isLast = false,
  });

  // Get colors based on status, matching your CSS
  Color _getBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'crossed':
        return const Color(0xFFF0F0F0); // .crossed
      case 'current':
        return AppTheme.accent; // .current
      case 'upcoming':
        return const Color(0xFFC2F5BA); // .upcoming
      default:
        return Colors.white;
    }
  }

  IconData _getIcon(String status) {
    switch (status.toLowerCase()) {
      case 'crossed':
        return Icons.check_circle;
      case 'current':
        return Icons.radio_button_checked; // Or Icons.my_location
      case 'upcoming':
        return Icons.radio_button_unchecked;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getBackgroundColor(stationStatus.status);
    final icon = _getIcon(stationStatus.status);
    final isDelayed = stationStatus.delay.toLowerCase() != 'on time';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. The Timeline Column
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst ? Colors.transparent : Colors.grey,
                  ),
                ),
                Icon(icon, color: Colors.blue[800]),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          // 2. The Details Card
          Expanded(
            child: Card(
              color: cardColor,
              elevation: 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.black, width: 1.0),
              ),
              margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stationStatus.stationName} (${stationStatus.index + 1})', // Added index for context
                      style: AppTheme.body.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    // Timings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         // Handle empty arrival/departure times
                        Text('Arr: ${stationStatus.arrivalTime.isEmpty ? "--:--" : stationStatus.arrivalTime}', style: AppTheme.body.copyWith(fontSize: 14)),
                        Text('Dep: ${stationStatus.departureTime.isEmpty ? "--:--" : stationStatus.departureTime}', style: AppTheme.body.copyWith(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Delay
                    Text(
                        stationStatus.delay.isEmpty ? "On Time" : stationStatus.delay, // Handle empty delay
                        style: AppTheme.body.copyWith(
                        color: isDelayed ? AppTheme.accentRed : Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}