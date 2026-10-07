class FlightResponse {
  final int total;
  final int pageSize;
  final int offset;
  final List<FlightData> flights;
  final String message;

  const FlightResponse({
    required this.total,
    required this.pageSize,
    required this.offset,
    required this.flights,
    required this.message,
  });

  factory FlightResponse.fromJson(Map<String, dynamic> json) {
    return FlightResponse(
      total: (json['TOTAL'] as num?)?.toInt() ?? 0,
      pageSize: (json['PAGE_SIZE'] as num?)?.toInt() ?? 20,
      offset: (json['OFFSET'] as num?)?.toInt() ?? 0,
      flights: (json['FLIGHTS'] as List<dynamic>? ?? [])
          .map((item) => FlightData.fromJson(item as Map<String, dynamic>))
          .toList(),
      message: json['MESSAGE']?.toString() ?? '',
    );
  }
}

class FlightData {
  final String airline;
  final String connection;
  final String flightDate;
  final String origin;
  final String destination;
  final String departureAirport;
  final String arrivalAirport;
  final String planeType;
  final int capacity;
  final int occupied;
  final int available;
  final double occupancy;
  final double price;
  final String currency;

  const FlightData({
    required this.airline,
    required this.connection,
    required this.flightDate,
    required this.origin,
    required this.destination,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.planeType,
    required this.capacity,
    required this.occupied,
    required this.available,
    required this.occupancy,
    required this.price,
    required this.currency,
  });

  factory FlightData.fromJson(Map<String, dynamic> json) {
    return FlightData(
      airline: json['CARRID']?.toString() ?? '',
      connection: json['CONNID']?.toString() ?? '',
      flightDate: _formatDate(json['FLDATE']?.toString() ?? ''),
      origin: json['CITYFROM']?.toString() ?? '',
      destination: json['CITYTO']?.toString() ?? '',
      departureAirport: json['AIRPFROM']?.toString() ?? '',
      arrivalAirport: json['AIRPTO']?.toString() ?? '',
      planeType: json['PLANETYPE']?.toString() ?? '',
      capacity: (json['SEATSMAX'] as num?)?.toInt() ?? 0,
      occupied: (json['SEATSOCC'] as num?)?.toInt() ?? 0,
      available: (json['AVAILABLE'] as num?)?.toInt() ?? 0,
      occupancy: (json['OCCUPANCY'] as num?)?.toDouble() ?? 0,
      price: (json['PRICE'] as num?)?.toDouble() ?? 0,
      currency: json['CURRENCY']?.toString() ?? '',
    );
  }

  static String _formatDate(String value) {
    if (value.length == 8) {
      return '${value.substring(6, 8)}/'
          '${value.substring(4, 6)}/'
          '${value.substring(0, 4)}';
    }

    if (value.contains('-')) {
      final parts = value.split('-');

      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    }

    return value;
  }
}
