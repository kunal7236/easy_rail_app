import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/availability.dart';
import '../utils/app_theme.dart';

class SeatAvailabilityChip extends StatelessWidget {
  final SeatAvailability seat;
  const SeatAvailabilityChip({super.key, required this.seat});

  @override
  Widget build(BuildContext context) {
    // Format fare
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    String formattedFare = currencyFormatter.format(seat.totalFare);

    return Container(
      width: 190, // The fixed width
      margin: const EdgeInsets.only(right: 8.0),
      
      // FIX 1: Reduce vertical padding to save space
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      
      decoration: BoxDecoration(
        color: seat.backgroundColor,
        border: Border.all(color: seat.statusColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // .seat-aval-header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // FIX 2: Wrap children in Flexible to prevent right overflow
              Flexible(
                child: Text(
                  '${seat.className} (${seat.quota})',
                  style: AppTheme.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                  // FIX 3: Force text to one line
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4), // Add a small gap
              Flexible(
                child: Text(
                  formattedFare,
                  style: AppTheme.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                  // FIX 3: Force text to one line
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // FIX 4: Reduce spacing
          const SizedBox(height: 6), 
          
          // .seat-aval-details
          Text(
            seat.availabilityStatus,
            style: AppTheme.body.copyWith(
              fontWeight: FontWeight.bold,
              color: seat.statusColor,
              // FIX 5: Slightly reduce font to fit
              fontSize: 15, 
            ),
            // FIX 3: Force text to one line
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // FIX 4: Reduce spacing
          const SizedBox(height: 2), 

          // .seat-aval-chance
          if (seat.prediction.isNotEmpty)
            Text(
              seat.prediction,
              style: AppTheme.body.copyWith(
                color: seat.statusColor.withValues(alpha: 0.8),
                fontSize: 12,
              ),
              // FIX 3: Force text to one line
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}