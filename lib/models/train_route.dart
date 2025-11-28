// A model to hold the parsed schedule
class TrainRoute {
  final String stationName;
  final String stationCode;
  final String arrivalTime;
  final String departureTime;
  final String distance;

  TrainRoute({
    required this.stationName,
    required this.stationCode,
    required this.arrivalTime,
    required this.departureTime,
    required this.distance,
  });
}