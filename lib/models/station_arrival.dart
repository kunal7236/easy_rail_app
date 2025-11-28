// Updated model to match the POST /at-station response
class StationArrival {
  final String trainNo;       // Changed from trainNo
  final String trainName;     // Changed from trainName
  final String source;
  final String destination;   // Changed from dest
  final String timeAt;        // Changed from timeat (and expectedArrival/Departure)

  StationArrival({
    required this.trainNo,
    required this.trainName,
    required this.source,
    required this.destination,
    required this.timeAt,
  });

  // Updated factory to use the correct JSON keys
  factory StationArrival.fromJson(Map<String, dynamic> json) {
    return StationArrival(
      trainNo: json['trainno'] as String? ?? 'N/A',       // Use 'trainno'
      trainName: json['trainname'] as String? ?? 'N/A',     // Use 'trainname'
      source: json['source'] as String? ?? 'N/A',
      destination: json['dest'] as String? ?? 'N/A',       // Use 'dest'
      timeAt: json['timeat'] as String? ?? '--:--',         // Use 'timeat'

    );
  }
}