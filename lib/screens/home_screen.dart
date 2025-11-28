import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/station.dart';
import '../providers/home_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/train_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controllers to manage the text in Autocomplete fields
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the provider
    final provider = context.watch<HomeProvider>();

    // Sync TextFields if stations are swapped in the provider
    if (provider.fromStation != null && _fromController.text.isEmpty) {
      _fromController.text = provider.fromStation.toString();
    }
    if (provider.toStation != null && _toController.text.isEmpty) {
      _toController.text = provider.toStation.toString();
    }
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // This is your '.main-box'
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(17.0),
            border: Border.all(color: AppTheme.accentDark, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.accentDark,
                blurRadius: 0,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text('Search Trains', style: AppTheme.heading),
              const SizedBox(height: 20),
              
              // 'From' and 'To' inputs with Swap icon
              Column(
                children: [
                  _buildStationAutocomplete(context, "From", _fromController, true),
                  
                  // Swap Icon
                  IconButton(
                    icon: const Icon(Icons.swap_vert, color: AppTheme.accentDark),
                    onPressed: () {
                      // Swap logic
                      context.read<HomeProvider>().swapStations();
                      // Manually swap controller text
                      final tempText = _fromController.text;
                      _fromController.text = _toController.text;
                      _toController.text = tempText;
                    },
                  ),
                  
                  _buildStationAutocomplete(context, "To", _toController, false),
                ],
              ),
              const SizedBox(height: 10),
              
              // Date Picker
              _buildDatePicker(context),
              const SizedBox(height: 20),
              
              // Search Button
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01FFD5), // Your hover color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    )
                  ),
                  onPressed: () {
                    context.read<HomeProvider>().searchTrains();
                  },
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // This is your '#train-results'
        _buildResultsArea(provider),
      ],
    );
  }

  /// Builds the Autocomplete widget for 'From' and 'To'
  Widget _buildStationAutocomplete(BuildContext context, String label, TextEditingController controller, bool isFrom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.label),
        const SizedBox(height: 8),
        Autocomplete<Station>(
          displayStringForOption: (Station option) => option.toString(),
          optionsBuilder: (TextEditingValue textEditingValue) {
            return context.read<HomeProvider>().searchStations(textEditingValue.text);
          },
          onSelected: (Station selection) {
            if (isFrom) {
              context.read<HomeProvider>().setFromStation(selection);
            } else {
              context.read<HomeProvider>().setToStation(selection);
            }
            controller.text = selection.toString(); // Update controller
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
                hintText: label == 'From' ? 'New Delhi' : 'Mumbai',
              ),
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
        ),
      ],
    );
  }

  /// Builds the custom Date Picker input
  Widget _buildDatePicker(BuildContext context) {
    final provider = context.read<HomeProvider>();
    String formattedDate = DateFormat('yyyy-MM-dd').format(provider.selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Journey Date', style: AppTheme.label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: provider.selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 120)),
            );
            if (picked != null && picked != provider.selectedDate) {
              provider.setSelectedDate(picked);
            }
          },
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: AppTheme.accentDark, width: 2.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formattedDate, style: AppTheme.body.copyWith(fontWeight: FontWeight.w600)),
                const Icon(Icons.calendar_today, color: AppTheme.accentDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the results area based on the provider state
  Widget _buildResultsArea(HomeProvider provider) {
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
        child: Text('Search for trains to see results.', style: AppTheme.body),
      );
    }

    // Display the list of train cards
    return Column(
      children: [
        Text(
          'Displaying ${provider.trains.length} Trains',
          style: AppTheme.heading.copyWith(decoration: TextDecoration.none),
        ),
        ListView.builder(
          itemCount: provider.trains.length,
          shrinkWrap: true, // Important inside a SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(), // Let the outer list scroll
          itemBuilder: (context, index) {
            final train = provider.trains[index];
            return TrainCard(train: train);
          },
        ),
      ],
    );
  }
}