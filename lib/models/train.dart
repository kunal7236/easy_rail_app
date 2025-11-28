// This model will now be based on the ConfirmTkt API response
class Train {
  final String trainNo;
  final String trainName;
  final String source;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final String travelTime;
  final List<String> runningDays; // This will now be a list of 7 "Y" or "N"
  final List<String> classes;

  Train({
    required this.trainNo,
    required this.trainName,
    required this.source,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.travelTime,
    required this.runningDays,
    required this.classes,
  });

  // Factory to create a Train from the new API
  factory Train.fromConfirmTkt(Map<String, dynamic> json) {
    // Convert the 'runningDays' string "Y,N,Y,..." into a List
    List<String> days = (json['runningDays'] as String? ?? 'N,N,N,N,N,N,N')
        .split(',');
        
    // Convert the 'classType' list
    List<String> classList = (json['classType'] as List? ?? [])
        .map((c) => c.toString())
        .toList();

    return Train(
      trainNo: json['trainNumber'] ?? 'N/A',
      trainName: json['trainName'] ?? 'Unknown',
      source: json['fromStnCode'] ?? 'N/A',
      destination: json['toStnCode'] ?? 'N/A',
      departureTime: json['departureTime'] ?? '--',
      arrivalTime: json['arrivalTime'] ?? '--',
      travelTime: json['duration'] ?? '--',
      runningDays: days,
      classes: classList,
    );
  }
}