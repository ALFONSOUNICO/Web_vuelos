class AirlineResponse {
  final List<AirlineData> airlines;

  const AirlineResponse({required this.airlines});

  factory AirlineResponse.fromJson(Map<String, dynamic> json) {
    return AirlineResponse(
      airlines: (json['AIRLINES'] as List<dynamic>? ?? [])
          .map((item) => AirlineData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AirlineData {
  final String airline;
  final int flights;
  final int bookings;
  final double occupancy;
  final int cancellations;

  const AirlineData({
    required this.airline,
    required this.flights,
    required this.bookings,
    required this.occupancy,
    required this.cancellations,
  });

  factory AirlineData.fromJson(Map<String, dynamic> json) {
    return AirlineData(
      airline: json['CARRID']?.toString() ?? '',
      flights: _number(json['FLIGHTS']),
      bookings: _number(json['BOOKINGS']),
      occupancy: _decimal(json['OCCUPANCY']),
      cancellations: _number(json['CANCELLATIONS']),
    );
  }

  static int _number(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _decimal(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
