// A model to hold basic train info
class TrainDetails {
  final String trainNo;
  final String trainName;
  final String sourceName;
  final String sourceCode;
  final String destName;
  final String destCode;
  final String trainId;
  final String departureTime;
  final String arrivalTime;
  final String travelTime;
  final String runningDays; // The "1111111" string

  TrainDetails({
    required this.trainNo,
    required this.trainName,
    required this.sourceName,
    required this.sourceCode,
    required this.destName,
    required this.destCode,
    required this.trainId,
    required this.departureTime,
    required this.arrivalTime,
    required this.travelTime,
    required this.runningDays,
  });
}
