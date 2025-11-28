import 'package:flutter/material.dart';
import '../models/station_arrival.dart';
import '../utils/app_theme.dart';

class StationTrainCard extends StatelessWidget {
  final StationArrival train;
  const StationTrainCard({super.key, required this.train});

  @override
  Widget build(BuildContext context) {
    // final bool isDelayed = train.delay.toLowerCase() != 'on time';

return Card(
      elevation: 2.0,
      color: AppTheme.accent,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
        side: const BorderSide(color: Colors.black, width: 2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Train Name and Number (Uses updated model fields)
            Text(
              '${train.trainNo} - ${train.trainName}',
              style: AppTheme.body.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(color: Colors.black45),

            // From -> To (Uses updated model fields)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(train.source, style: AppTheme.body, overflow: TextOverflow.ellipsis)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(Icons.arrow_forward, size: 16),
                ),
                Flexible(child: Text(train.destination, style: AppTheme.body, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 12),

            // --- UPDATED: Show Time At Station ---
            Center(
              child: _buildInfoColumn('Time At Station', train.timeAt),
            ),
            // --- REMOVED Delay ---
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTheme.body.copyWith(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}