import 'package:flutter/material.dart';
import '../models/availability.dart';
import '../utils/app_theme.dart';
import 'seat_availability_chip.dart';

class TrainAvailabilityCard extends StatelessWidget {
  final TrainAvailability train;
  final VoidCallback? onScheduleTap;

  const TrainAvailabilityCard({
    super.key,
    required this.train,
    this.onScheduleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // .train-header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${train.trainNumber} - ${train.trainName}',
                    style: AppTheme.body.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (train.pantry)
                  const Icon(
                    Icons.restaurant_menu,
                    color: Colors.blue,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // .train-data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // .train-timings
                Row(
                  children: [
                    Text(
                      train.departureTime,
                      style: AppTheme.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(' ${train.fromStnCode}', style: AppTheme.body),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        train.duration,
                        style: AppTheme.body.copyWith(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Text(
                      train.arrivalTime,
                      style: AppTheme.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(' ${train.toStnCode}', style: AppTheme.body),
                  ],
                ),
                // .train-sche-link
                TextButton(
                  onPressed: onScheduleTap,
                  child: Text(
                    'Schedule',
                    style: AppTheme.body.copyWith(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // .seats (Horizontal List)
            SizedBox(
              height: 90, // Fixed height for the horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: train.availabilityList.length,
                itemBuilder: (context, index) {
                  return SeatAvailabilityChip(
                    seat: train.availabilityList[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
