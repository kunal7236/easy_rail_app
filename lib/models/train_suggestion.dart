class TrainSuggestion {
  final String name;
  final String number;

  TrainSuggestion({required this.name, required this.number});
  factory TrainSuggestion.fromJson(Map<String, dynamic> json) {
      return TrainSuggestion(
        name: json['trainName'] as String? ?? 'Unknown Train', 
        number: json['trainno'] as String? ?? '00000',
      );
    }
  /// Used by Autocomplete to display the string
  @override
  String toString() {
    return '$name ($number)';
  }
}