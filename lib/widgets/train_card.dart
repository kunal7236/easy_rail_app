import 'package:flutter/material.dart';
import '../models/train.dart';
import '../utils/app_theme.dart';

class TrainCard extends StatelessWidget {
  final Train train;
  const TrainCard({super.key, required this.train});

  @override
  Widget build(BuildContext context) {
    // Replicates your 'running-days' logic
    final List<String> dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    List<Widget> dayWidgets = [];
    for (int i = 0; i < 7; i++) {
      dayWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Text(
            dayLabels[i],
            style: TextStyle(
              fontSize: 12,
              color: train.runningDays[i] == 'Y' ? Colors.black : Colors.grey[300],
              fontWeight: train.runningDays[i] == 'Y' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 3.0,
      color: const Color(0xFFDDF7F3), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Colors.black, width: 1.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // .train-header
            Text(
              '${train.trainNo} - ${train.trainName}',
              style: AppTheme.body.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            
            // .train-body
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn(train.departureTime, train.source),
                Column(
                  children: [
                    Text(train.travelTime, style: AppTheme.body.copyWith(color: Colors.black54, fontSize: 12)),
                    const Text('---', style: TextStyle(color: Colors.black54)),
                  ],
                ),
                _buildTimeColumn(train.arrivalTime, train.destination),
              ],
            ),
            const SizedBox(height: 16),
            
            // .train-footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Running Days
                Row(
                  children: dayWidgets,
                ),
                // Classes
                Flexible(
                  child: Text(
                    train.classes.join(' '),
                    style: AppTheme.body.copyWith(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String time, String station) {
    return Column(
      children: [
        Text(time, style: AppTheme.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(station, style: AppTheme.body.copyWith(color: Colors.black87)),
      ],
    );
  }
}