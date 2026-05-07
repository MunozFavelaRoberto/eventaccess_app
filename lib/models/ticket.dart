class Ticket {
  final int id;
  final String name; // event name
  final String placeName;
  final String address;
  final String date;
  final String receptionTime;
  final String startTime;
  final String endTime;
  final String ticketCode;
  final String qrB64;
  final String displayId;

  Ticket({
    required this.id,
    required this.name,
    required this.placeName,
    required this.address,
    required this.date,
    required this.receptionTime,
    required this.startTime,
    required this.endTime,
    required this.ticketCode,
    required this.qrB64,
    required this.displayId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      name: json['name'] as String,
      placeName: json['place_name'] as String,
      address: json['address'] as String,
      date: json['date'] as String,
      receptionTime: json['reception_time'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      ticketCode: json['ticket_code'] as String,
      qrB64: json['qr_b64'] as String,
      displayId: json['display_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'place_name': placeName,
      'address': address,
      'date': date,
      'reception_time': receptionTime,
      'start_time': startTime,
      'end_time': endTime,
      'ticket_code': ticketCode,
      'qr_b64': qrB64,
      'display_id': displayId,
    };
  }
}