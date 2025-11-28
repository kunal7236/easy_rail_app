import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/at_station_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/station_train_card.dart';

class AtStationScreen extends StatefulWidget {
  const AtStationScreen({super.key});

  @override
  State<AtStationScreen> createState() => _AtStationScreenState();
}

class _AtStationScreenState extends State<AtStationScreen> {
  final TextEditingController _stationController = TextEditingController();

  @override
  void dispose() {
    _stationController.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    context.read<AtStationProvider>().fetchTrainsAtStation(_stationController.text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AtStationProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Station Live', style: AppTheme.heading, textAlign: TextAlign.center),
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
                    Text('Enter Station Code', style: AppTheme.label),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _stationController,
                      decoration: const InputDecoration(
                        hintText: 'Ex: NDLS or HWH',
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _search,
                        child: const Text('Search'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // This is your '#trainStationContainer'
        Expanded(
          child: _buildResultsArea(provider),
        ),
      ],
    );
  }

  /// Builds the results area based on the provider state
  Widget _buildResultsArea(AtStationProvider provider) {
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
        child: Text('Enter a station code to see live arrivals/departures.', style: AppTheme.body),
      );
    }

    // Results Found
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: provider.trains.length,
      itemBuilder: (context, index) {
        final train = provider.trains[index];
        return StationTrainCard(train: train);
      },
    );
  }
}