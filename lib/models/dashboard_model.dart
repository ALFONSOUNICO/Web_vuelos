class DashboardData {
  final DashboardKpis kpis;
  final List<MonthlyData> monthly;
  final List<AirlineData> airlines;
  final List<RouteData> routes;

  const DashboardData({
    required this.kpis,
    required this.monthly,
    required this.airlines,
    required this.routes,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      kpis: DashboardKpis.fromJson(json['KPIS'] as Map<String, dynamic>),
      monthly: (json['MONTHLY'] as List<dynamic>? ?? [])
          .map((item) => MonthlyData.fromJson(item as Map<String, dynamic>))
          .toList(),
      airlines: (json['AIRLINES'] as List<dynamic>? ?? [])
          .map((item) => AirlineData.fromJson(item as Map<String, dynamic>))
          .toList(),
      routes: (json['ROUTES'] as List<dynamic>? ?? [])
          .map((item) => RouteData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardKpis {
  final int totalFlights;
  final int totalBookings;
  final int activeAirlines;
  final int connections;
  final int customers;
  final int flightsWithoutBookings;
  final int cancellations;
  final double globalOccupancy;

  const DashboardKpis({
    required this.totalFlights,
    required this.totalBookings,
    required this.activeAirlines,
    required this.connections,
    required this.customers,
    required this.flightsWithoutBookings,
    required this.cancellations,
    required this.globalOccupancy,
  });

  factory DashboardKpis.fromJson(Map<String, dynamic> json) {
    return DashboardKpis(
      totalFlights: (json['TOTAL_FLIGHTS'] as num?)?.toInt() ?? 0,
      totalBookings: (json['TOTAL_BOOKINGS'] as num?)?.toInt() ?? 0,
      activeAirlines: (json['ACTIVE_AIRLINES'] as num?)?.toInt() ?? 0,
      connections: (json['CONNECTIONS'] as num?)?.toInt() ?? 0,
      customers: (json['CUSTOMERS'] as num?)?.toInt() ?? 0,
      flightsWithoutBookings:
          (json['FLIGHTS_WITHOUT_BOOKINGS'] as num?)?.toInt() ?? 0,
      cancellations: (json['CANCELLATIONS'] as num?)?.toInt() ?? 0,
      globalOccupancy: (json['GLOBAL_OCCUPANCY'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MonthlyData {
  final String period;
  final int flights;
  final int bookings;

  const MonthlyData({
    required this.period,
    required this.flights,
    required this.bookings,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      period: json['PERIOD']?.toString() ?? '',
      flights: (json['FLIGHTS'] as num?)?.toInt() ?? 0,
      bookings: (json['BOOKINGS'] as num?)?.toInt() ?? 0,
    );
  }
}

class AirlineData {
  final String airline;
  final int bookings;
  final int capacity;
  final int occupied;
  final double occupancy;

  const AirlineData({
    required this.airline,
    required this.bookings,
    required this.capacity,
    required this.occupied,
    required this.occupancy,
  });

  factory AirlineData.fromJson(Map<String, dynamic> json) {
    return AirlineData(
      airline: json['AIRLINE']?.toString() ?? '',
      bookings: (json['BOOKINGS'] as num?)?.toInt() ?? 0,
      capacity: (json['CAPACITY'] as num?)?.toInt() ?? 0,
      occupied: (json['OCCUPIED'] as num?)?.toInt() ?? 0,
      occupancy: (json['OCCUPANCY'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RouteData {
  final String route;
  final int bookings;

  const RouteData({required this.route, required this.bookings});

  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      route: json['ROUTE']?.toString() ?? '',
      bookings: (json['BOOKINGS'] as num?)?.toInt() ?? 0,
    );
  }
}
