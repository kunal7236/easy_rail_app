import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../models/live_status.dart';
import '../providers/live_status_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/station_timeline_card.dart';

class LiveStatusScreen extends StatefulWidget {
  const LiveStatusScreen({super.key});

  @override
  State<LiveStatusScreen> createState() => _LiveStatusScreenState();
}

class _LiveStatusScreenState extends State<LiveStatusScreen> {
  final TextEditingController _trainController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Controller for the scrollable list
  final ItemScrollController _scrollController = ItemScrollController();

  @override
  void dispose() {
    _trainController.dispose();
    // Manually clear provider state when screen is disposed
    // This stops the timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LiveStatusProvider>(context, listen: false).clearStatus();
    });
    super.dispose();
  }

  void _searchStatus() {
    FocusScope.of(context).unfocus();
    if (_trainController.text.isNotEmpty) {
      context.read<LiveStatusProvider>().fetchLiveStatus(
        _trainController.text,
        _selectedDate,
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to easily rebuild when provider changes
    return Consumer<LiveStatusProvider>(
      builder: (context, provider, child) {
        // This is the logic to scroll to the item after the build
        if (provider.stations.isNotEmpty &&
            provider.currentStationIndex != -1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.isAttached) {
              _scrollController.scrollTo(
                index: provider.currentStationIndex,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                alignment: 0.3,
              );
            }
          });
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Train Running Status',
                style: AppTheme.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Search Form
              _buildSearchForm(context),
              const SizedBox(height: 20),

              // Results Area
              _buildResultsArea(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchForm(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Card(
      elevation: 2.0,
      color: const Color(0xFFCCE5EB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: AppTheme.accentDark, width: 2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _trainController,
              decoration: const InputDecoration(
                labelText: 'Train Number',
                hintText: 'Ex: 12345',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
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
                    Text(
                      formattedDate,
                      style: AppTheme.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.accentDark,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchStatus,
                child: const Text('Check Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsArea(LiveStatusProvider provider) {
    if (provider.isLoading && provider.stations.isEmpty) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (provider.error != null) {
      return Text(
        provider.error!,
        style: const TextStyle(color: AppTheme.accentRed, fontSize: 16),
        textAlign: TextAlign.center,
      );
    }

    if (provider.stations.isEmpty) {
      return Text(
        'Enter a train number to get live status.',
        style: AppTheme.body,
        textAlign: TextAlign.center,
      );
    }

    // Results Found
    final stations = provider.stations;
    final currentStation = stations.firstWhere(
      (s) => s.isCurrent,
      orElse: () => stations.isNotEmpty
          ? stations.first
          : LiveStationStatus(
              index: -1,
              stationName: 'N/A',
              arrivalTime: '',
              departureTime: '',
              delay: '',
              status: '',
              isCurrent: false,
            ), // Dummy object if not found
    );
    return Expanded(
      child: Column(
        children: [
          // Header with train info
          Text(
            "Train Number: ${_trainController.text}",
            style: AppTheme.body.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Current: ${currentStation.stationName}',
            style: AppTheme.body.copyWith(fontSize: 16),
          ),

          const SizedBox(height: 10),

          // The Timeline List
          Expanded(
            child: ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                return StationTimelineCard(
                  stationStatus: station, // Pass the new object type
                  isFirst: index == 0,
                  isLast: index == stations.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
