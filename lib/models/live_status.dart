// --- UPDATED LiveStation MODEL ---
// Renamed from LiveStation, now represents the top-level objects in the list
class LiveStationStatus {
  final int index;
  final String stationName; // Changed from 'station'
  final String arrivalTime; // Changed from 'arr'
  final String departureTime; // Changed from 'dep'
  final String delay;
  final String status;
  final bool isCurrent; // Changed from 'current' (String to bool)

  LiveStationStatus({
    required this.index,
    required this.stationName,
    required this.arrivalTime,
    required this.departureTime,
    required this.delay,
    required this.status,
    required this.isCurrent,
  });

  // Updated factory to match new keys and types
  factory LiveStationStatus.fromJson(Map<String, dynamic> json) {
    return LiveStationStatus(
      index: json['index'] as int? ?? -1,
      stationName: json['station'] as String? ?? 'N/A', // Use 'station' key
      arrivalTime: json['arr'] as String? ?? '',       // Use 'arr' key
      departureTime: json['dep'] as String? ?? '',     // Use 'dep' key
      delay: json['delay'] as String? ?? 'On Time',
      status: json['status'] as String? ?? 'upcoming',
      // Convert 'current' string ("true"/"false") to boolean
      isCurrent: (json['current'] as String? ?? 'false').toLowerCase() == 'true',
    );
  }
}