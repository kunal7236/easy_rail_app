import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/train_search_provider.dart';
import '../models/train_suggestion.dart';

import '../utils/app_theme.dart';
import '../widgets/station_route_card.dart';
import '../models/train_details.dart';
import '../models/train_route.dart';

class TrainSearchScreen extends StatefulWidget {
  const TrainSearchScreen({super.key});

  @override
  State<TrainSearchScreen> createState() => _TrainSearchScreenState();
}

class _TrainSearchScreenState extends State<TrainSearchScreen> {
  final TextEditingController _trainController = TextEditingController();

  @override
  void dispose() {
    _trainController.dispose();
    super.dispose();
  }

  void _searchTrain() {
    FocusScope.of(context).unfocus(); // Hide keyboard
    context.read<TrainSearchProvider>().fetchTrainDetails();
  }

  @override
  Widget build(BuildContext context) {
    // Use .watch() to rebuild when the provider notifies
    final provider = context.watch<TrainSearchProvider>();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'Train Timetable',
          style: AppTheme.heading,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // This is your '.search-container'
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: const Color(0xFFCCE5EB), // from .search-container
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: AppTheme.accentDark, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter Train Name or Number', style: AppTheme.label),
              const SizedBox(height: 10),

              // Autocomplete for Train Search
              Autocomplete<TrainSuggestion>(
                displayStringForOption: (TrainSuggestion option) =>
                    option.toString(),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  // Use .read() inside a builder
                  return context.read<TrainSearchProvider>().searchTrains(
                    textEditingValue.text,
                  );
                },
                onSelected: (TrainSuggestion selection) {
                  context.read<TrainSearchProvider>().setSelectedTrain(
                    selection,
                  );
                  _trainController.text = selection.toString();
                },
                fieldViewBuilder:
                    (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      // Sync external controller with Autocomplete's internal controller
                      textEditingController.text = _trainController.text;
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Ex: 12312 or NETAJI EXPRESS',
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
                            final TrainSuggestion option = options.elementAt(
                              index,
                            );
                            return InkWell(
                              onTap: () {
                                onSelected(option);
                              },
                              child: ListTile(title: Text(option.toString())),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _searchTrain,
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // This is '#train-details' and '#schedule-container'
        _buildResultsArea(provider),
      ],
    );
  }

  /// Builds the result area based on the provider's state
  Widget _buildResultsArea(TrainSearchProvider provider) {
    if (provider.isLoading && provider.trainDetails == null) {
      // Show main loader only on first load
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

    if (provider.trainDetails == null) {
      return Center(
        child: Text(
          'Search for a train to see its timetable.',
          style: AppTheme.body,
        ),
      );
    }

    // If we have data, build the results
    return Column(
      children: [
        // This is '#train-details'
        _buildTrainDetailsCard(provider.trainDetails!),

        const SizedBox(height: 30),

        // This is '.schedule-container'
        if (provider.trainRoute.isNotEmpty)
          _buildScheduleTable(provider.trainRoute)
        else if (provider.isLoading)
          // Show a smaller loader while route is fetching
          const Center(child: CircularProgressIndicator())
        else
          // Fallback if route failed but details succeeded
          const Center(child: Text('Could not load train route.')),
      ],
    );
  }

  // Replicates '#train-table'
Widget _buildTrainDetailsCard(TrainDetails details) {
    // --- FORMAT RUNNING DAYS ---
    final List<String> weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    String runningDaysFormatted = '';
    if (details.runningDays.length == 7) {
      runningDaysFormatted = details.runningDays
          .split('')
          .asMap() // Get index
          .map((index, bit) => MapEntry(
              index, bit == '1' ? weekdays[index] : '_')) // Map 1/0 to Day/_
          .values
          .join(' '); // Join with spaces
    } else {
      runningDaysFormatted = 'N/A'; // Fallback
    }
    

    return Card(
      elevation: 2.0,
      color: AppTheme.accent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Train Name (Number)
            Text(
              '${details.trainName} (${details.trainNo})',
              style: AppTheme.heading.copyWith(fontSize: 20, decoration: TextDecoration.none),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 15, thickness: 1), // Add a divider


            _buildDetailRow('Source:', '${details.sourceName} (${details.sourceCode})'),
     
            _buildDetailRow('Destination:', '${details.destName} (${details.destCode})'),
            

            _buildDetailRow('Departure:', details.departureTime),
            _buildDetailRow('Arrival:', details.arrivalTime),
            _buildDetailRow('Travel Time:', details.travelTime),
            _buildDetailRow('Running Days:', runningDaysFormatted),
  

          ],
        ),
      ),
    );
  }
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTheme.label.copyWith(fontSize: 16)),
          const SizedBox(width: 10),
          Text(value, style: AppTheme.body),
        ],
      ),
    );
  }


  Widget _buildScheduleTable(List<TrainRoute> route) {
    return Column(
      children: [
        Text('Train Schedule', style: AppTheme.heading),
        const SizedBox(height: 10),

        ListView.builder(
          // Set physics and shrinkWrap to use inside another list
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: route.length,
          itemBuilder: (context, index) {
            final stop = route[index];
            return StationRouteCard(
              stop: stop,
              stopNumber: index + 1, // Pass the stop number
              isFirst: index == 0,
              isLast: index == route.length - 1,
            );
          },
        ),
      ],
    );
  }
}
