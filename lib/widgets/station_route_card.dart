import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../models/train_route.dart';

class StationRouteCard extends StatelessWidget {
  final TrainRoute stop;
  final int stopNumber;
  final bool isFirst;
  final bool isLast;

  const StationRouteCard({
    super.key,
    required this.stop,
    required this.stopNumber,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. The Timeline Column
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst ? Colors.transparent : Colors.grey,
                  ),
                ),
                // The stop number (1, 2, 3...)
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.accentDark,
                  child: Text(
                    '$stopNumber',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
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
              elevation: 1.0,
              margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stop.stationName} (${stop.stationCode})',
                      style: AppTheme.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward, size: 16, color: Colors.green),
                        Text(' Arr: ${stop.arrivalTime}', style: AppTheme.body.copyWith(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward, size: 16, color: Colors.red),
                        Text(' Dep: ${stop.departureTime}', style: AppTheme.body.copyWith(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Distance: ${stop.distance} km',
                      style: AppTheme.body.copyWith(fontSize: 12, color: Colors.black54),
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