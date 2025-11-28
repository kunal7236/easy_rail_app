class Station {
  final String name;
  final String code;

  Station({required this.name, required this.code});

  factory Station.fromJson(Map<String, dynamic> json) {
      return Station(
        name: json['stnName'] as String? ?? 'Unknown Name', 
        code: json['stnCode'] as String? ?? 'XXX',
      );
    }
  /// Used by Autocomplete to display the string
  @override
  String toString() {
    return '$name ($code)';
  }
}