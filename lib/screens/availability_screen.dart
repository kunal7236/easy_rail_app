import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/station.dart';
import '../providers/availability_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/train_availability_card.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _updateDate(DateTime newDate) {
    context.read<AvailabilityProvider>().setSelectedDate(newDate);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvailabilityProvider>();
    
    // Determine which date tab is active
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfter = today.add(const Duration(days: 2));

    List<bool> isSelected = [
      provider.selectedDate == today,
      provider.selectedDate == tomorrow,
      provider.selectedDate == dayAfter,
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // This is your '.booking-container'
        Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStationAutocomplete(context, "From Station", _fromController, true),
                const Divider(height: 20),
                _buildStationAutocomplete(context, "To Station", _toController, false),
                const Divider(height: 20),
                _buildDatePicker(context, isSelected),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D9DDA), // .search-button color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                    ),
                    onPressed: () {
                      context.read<AvailabilityProvider>().fetchAvailability();
                    },
                    child: const Text('Get Availability', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // This is your '.aval-container'
        _buildResultsArea(provider),
      ],
    );
  }

  /// Builds the Autocomplete widget (similar to home_screen)
  Widget _buildStationAutocomplete(BuildContext context, String hint, TextEditingController controller, bool isFrom) {
    return Autocomplete<Station>(
      displayStringForOption: (Station option) => option.toString(),
      optionsBuilder: (TextEditingValue textEditingValue) {
        return context.read<AvailabilityProvider>().searchStations(textEditingValue.text);
      },
      onSelected: (Station selection) {
        if (isFrom) {
          context.read<AvailabilityProvider>().setFromStation(selection);
        } else {
          context.read<AvailabilityProvider>().setToStation(selection);
        }
        controller.text = selection.toString();
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        // Assign the external controller
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.text.isNotEmpty && textEditingController.text.isEmpty) {
            textEditingController.text = controller.text;
          }
        });
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(isFrom ? Icons.departure_board : Icons.pin_drop),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          style: AppTheme.body.copyWith(fontWeight: FontWeight.w500),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final Station option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option.toString()),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the custom Date Picker with tabs
  Widget _buildDatePicker(BuildContext context, List<bool> isSelected) {
    final provider = context.read<AvailabilityProvider>();
    String formattedDate = DateFormat('dd-MM-yyyy').format(provider.selectedDate);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return Column(
      children: [
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: provider.selectedDate,
              firstDate: today,
              lastDate: today.add(const Duration(days: 120)),
            );
            if (picked != null && picked != provider.selectedDate) {
              _updateDate(picked);
            }
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.accentDark),
                const SizedBox(width: 15),
                Text(formattedDate, style: AppTheme.body.copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        ToggleButtons(
          isSelected: isSelected,
          onPressed: (int index) {
            if (index == 0) _updateDate(today);
            if (index == 1) _updateDate(today.add(const Duration(days: 1)));
            if (index == 2) _updateDate(today.add(const Duration(days: 2)));
          },
          borderRadius: BorderRadius.circular(4.0),
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Today')),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Tomorrow')),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Day After')),
          ],
        ),
      ],
    );
  }

  /// Builds the results area
  Widget _buildResultsArea(AvailabilityProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: const TextStyle(color: AppTheme.accentRed, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (provider.trains.isEmpty) {
      return Center(
        child: Text('Search for availability to see results.', style: AppTheme.body),
      );
    }

    // Display the list of train cards
    return ListView.builder(
      itemCount: provider.trains.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final train = provider.trains[index];
        return TrainAvailabilityCard(train: train);
      },
    );
  }
}