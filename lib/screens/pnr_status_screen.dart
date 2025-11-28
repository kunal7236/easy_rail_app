import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pnr_provider.dart';
import '../utils/app_theme.dart';
import '../models/pnr_status.dart';

class PnrStatusScreen extends StatefulWidget {
  const PnrStatusScreen({super.key});

  @override
  State<PnrStatusScreen> createState() => _PnrStatusScreenState();
}

class _PnrStatusScreenState extends State<PnrStatusScreen> {
  final _pnrController = TextEditingController();

  void _searchPnr() {
    // Use 'context.read' to call a function
    Provider.of<PnrProvider>(
      context,
      listen: false,
    ).fetchPnrStatus(_pnrController.text);
  }

  @override
  Widget build(BuildContext context) {
    // Use 'context.watch' to listen for changes
    final pnrProvider = context.watch<PnrProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'PNR Enquiry',
            style: AppTheme.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // This is your '.search-container'
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFFCCE5EB),
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
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enter PNR Number', style: AppTheme.label),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _pnrController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      hintText: 'XXXXXXXXXX',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _searchPnr,
                      child: const Text('Search'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // This is your '#output' div
          _buildPnrResult(pnrProvider),
        ],
      ),
    );
  }

  // This widget handles the different states: loading, error, or success
  Widget _buildPnrResult(PnrProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Text(
        provider.error!,
        style: const TextStyle(color: AppTheme.accentRed, fontSize: 16),
        textAlign: TextAlign.center,
      );
    }
    if (provider.pnrData == null) {
      return Text(
        'Enter a PNR to get status.',
        style: AppTheme.body,
        textAlign: TextAlign.center,
      );
    }
    return _PnrDetailsCard(data: provider.pnrData!);
  }
}

// A dedicated widget for displaying the results
class _PnrDetailsCard extends StatelessWidget {
  final PnrData data;
  const _PnrDetailsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${data.trainName} (${data.trainNumber})',
              style: AppTheme.heading.copyWith(
                decoration: TextDecoration.none,
                fontSize: 20,
              ),
            ),
            const Divider(height: 20),
            _buildDetailRow('PNR:', data.pnrNumber),
            _buildDetailRow('From:', data.sourceStation),
            _buildDetailRow('To:', data.destinationStation),
            _buildDetailRow('Journey Date:', data.dateOfJourney),
            _buildDetailRow('Class:', data.journeyClass),
            _buildDetailRow('Chart Status:', data.chartStatus),
            const Divider(height: 20),
            Text(
              'Passenger Details',
              style: AppTheme.label.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 10),
            // Build the passenger table
            SingleChildScrollView(
              // Wrap DataTable for horizontal scrolling if needed
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('S.No')), // Added label:
                  DataColumn(label: Text('Booking Status')), // Added label:
                  DataColumn(label: Text('Current Status')), // Added label:
                ],

                rows: data.passengerList
                    .map(
                      (p) => DataRow(
                        cells: [
                          DataCell(Text(p.passengerSerialNumber.toString())),
                          DataCell(Text(p.bookingStatusDetails)),
                          DataCell(
                            Text(
                              p.currentStatusDetails,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: AppTheme.label),
          const SizedBox(width: 10),
          Text(value, style: AppTheme.body),
        ],
      ),
    );
  }
}
