// Updated model to perfectly match the successful JSON response

class PnrStatusResponse {
  final bool success;
  final PnrData? data;

  PnrStatusResponse({required this.success, this.data});

  factory PnrStatusResponse.fromJson(Map<String, dynamic> json) {
    return PnrStatusResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? PnrData.fromJson(json['data']) : null,
    );
  }
}

class PnrData {
  final String pnrNumber;
  final String dateOfJourney; // Kept as String for simplicity
  final String trainNumber;
  final String trainName;
  final String sourceStation;
  final String destinationStation;
  final String journeyClass;
  final String chartStatus;
  final List<Passenger> passengerList;

  PnrData({
    required this.pnrNumber,
    required this.dateOfJourney,
    required this.trainNumber,
    required this.trainName,
    required this.sourceStation,
    required this.destinationStation,
    required this.journeyClass,
    required this.chartStatus,
    required this.passengerList,
  });

  factory PnrData.fromJson(Map<String, dynamic> json) {
    var passengersFromJson = json['passengerList'] as List? ?? [];
    List<Passenger> passengers = passengersFromJson.map((i) => Passenger.fromJson(i)).toList();

    return PnrData(
      pnrNumber: json['pnrNumber'] ?? 'N/A',
      dateOfJourney: json['dateOfJourney'] ?? 'N/A', // Keep original format
      trainNumber: json['trainNumber'] ?? 'N/A',
      trainName: json['trainName'] ?? 'N/A',
      sourceStation: json['sourceStation'] ?? 'N/A',
      destinationStation: json['destinationStation'] ?? 'N/A',
      journeyClass: json['journeyClass'] ?? 'N/A',
      chartStatus: json['chartStatus'] ?? 'N/A',
      passengerList: passengers,
    );
  }
}

class Passenger {
  final int passengerSerialNumber;
  final String bookingStatusDetails; // e.g., "CNF/B2/41/LB"
  final String currentStatusDetails; // e.g., "CNF/B2/41/LB"

  Passenger({
    required this.passengerSerialNumber,
    required this.bookingStatusDetails,
    required this.currentStatusDetails,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      passengerSerialNumber: json['passengerSerialNumber'] ?? 0,
      // Use the combined status fields
      bookingStatusDetails: json['bookingStatusDetails'] ?? 'N/A',
      currentStatusDetails: json['currentStatusDetails'] ?? 'N/A',
    );
  }
}