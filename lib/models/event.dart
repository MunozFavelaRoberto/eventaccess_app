class Event {
  final String name;
  final String placeName;
  final String date;
  final String receptionTime;
  final String startTime;
  final String endTime;

  Event({
    required this.name,
    required this.placeName,
    required this.date,
    required this.receptionTime,
    required this.startTime,
    required this.endTime,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'] as String,
      placeName: json['place_name'] as String,
      date: json['date'] as String,
      receptionTime: json['reception_time'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'place_name': placeName,
      'date': date,
      'reception_time': receptionTime,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}