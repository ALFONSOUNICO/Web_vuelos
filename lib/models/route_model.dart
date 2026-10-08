class RouteData {
  final String airline;
  final String flight;
  final String origin;
  final String destination;
  final int flights;
  final int bookings;
  final int duration;
  final double distance;
  final String distanceUnit;
  final double occupancy;

  const RouteData({
    required this.airline,
    required this.flight,
    required this.origin,
    required this.destination,
    required this.flights,
    required this.bookings,
    required this.duration,
    required this.distance,
    required this.distanceUnit,
    required this.occupancy,
  });

  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      airline: (json['CARRID'] ?? json['AIRLINE'] ?? '').toString(),
      flight: (json['CONNID'] ?? json['FLIGHT'] ?? '').toString(),
      origin: (json['CITYFROM'] ?? json['ORIGIN'] ?? '').toString(),
      destination: (json['CITYTO'] ?? json['DESTINATION'] ?? '').toString(),
      flights: _toInt(json['FLIGHTS']),
      bookings: _toInt(json['BOOKINGS']),
      duration: _toInt(json['FLTIME']),
      distance: _toDouble(json['DISTANCE']),
      distanceUnit: (json['DISTID'] ?? json['DISTANCEUNIT'] ?? '').toString(),
      occupancy: _toDouble(json['OCCUPANCY']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class RouteResponse {
  final int total;
  final int pageSize;
  final int offset;
  final List<RouteData> routes;
  final String message;

  const RouteResponse({
    required this.total,
    required this.pageSize,
    required this.offset,
    required this.routes,
    required this.message,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    final rawRoutes = json['ROUTES'] ?? json['routes'] ?? [];

    return RouteResponse(
      total: _toInt(json['TOTAL']),
      pageSize: _toInt(json['PAGE_SIZE']),
      offset: _toInt(json['OFFSET']),
      routes: (rawRoutes as List)
          .map(
            (item) => RouteData.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      message: (json['MESSAGE'] ?? json['message'] ?? '').toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}