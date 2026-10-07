import 'package:flutter/material.dart';

import '../models/dashboard_model.dart';
import '../services/sap_service.dart';
import '../theme/app_theme.dart';

class DashboardPage extends StatefulWidget {
  final String usuario;
  final String password;

  const DashboardPage({
    super.key,
    required this.usuario,
    required this.password,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final SapService _sapService = SapService();

  DashboardData? _dashboard;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _sapService.getDashboard(
        usuario: widget.usuario,
        password: widget.password,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _dashboard = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_dashboard == null) {
      return _buildErrorState(message: 'No se recibieron datos desde SAP.');
    }

    return _buildDashboard(_dashboard!);
  }

  Widget _buildDashboard(DashboardData dashboard) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1100;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 28 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isWide),
                const SizedBox(height: 26),
                _buildKpiGrid(isWide, dashboard),
                const SizedBox(height: 24),
                _buildMainCharts(isWide, dashboard),
                const SizedBox(height: 24),
                _buildOperationalSummary(isWide, dashboard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: AppTheme.primaryRed,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Consultando información de SAP',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Cargando información del Dashboard...',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState({String? message}) {
    final errorMessage = message ?? _error ?? 'No fue posible consultar SAP.';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: AppTheme.primaryRed,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No fue posible consultar SAP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: _loadDashboard,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isWide) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.primaryRed,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.flight_takeoff_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SAP Flight Analytics',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Centro de análisis y seguimiento de operaciones aéreas',
                style: TextStyle(
                  fontSize: isWide ? 15 : 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (isWide)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.cloud_done_rounded, size: 18, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Datos SAP disponibles',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildKpiGrid(bool isWide, DashboardData dashboard) {
    final kpis = dashboard.kpis;

    final cards = [
      _KpiData(
        title: 'Vuelos programados',
        value: _formatNumber(kpis.totalFlights),
        subtitle: 'Periodo analizado',
        icon: Icons.flight_rounded,
        color: AppTheme.primaryRed,
      ),
      _KpiData(
        title: 'Reservas registradas',
        value: _formatNumber(kpis.totalBookings),
        subtitle: 'Reservas procesadas',
        icon: Icons.confirmation_number_rounded,
        color: AppTheme.navyBlue,
      ),
      _KpiData(
        title: 'Aerolíneas activas',
        value: _formatNumber(kpis.activeAirlines),
        subtitle: 'Con vuelos registrados',
        icon: Icons.business_rounded,
        color: const Color(0xFF2E6F95),
      ),
      _KpiData(
        title: 'Nivel de ocupación',
        value: '${kpis.globalOccupancy.toStringAsFixed(2)}%',
        subtitle: 'Ocupación global',
        icon: Icons.event_seat_rounded,
        color: const Color(0xFFB45309),
      ),
      _KpiData(
        title: 'Clientes con reservas',
        value: _formatNumber(kpis.customers),
        subtitle: 'Clientes atendidos',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF475569),
      ),
      _KpiData(
        title: 'Cancelaciones',
        value: _formatNumber(kpis.cancellations),
        subtitle: 'Reservas canceladas',
        icon: Icons.cancel_rounded,
        color: const Color(0xFF991B1B),
      ),
    ];

    if (isWide) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.35,
        ),
        itemBuilder: (context, index) {
          return _buildKpiCard(cards[index]);
        },
      );
    }

    return Column(
      children: cards
          .map(
            (card) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildKpiCard(card),
            ),
          )
          .toList(),
    );
  }

  Widget _buildKpiCard(_KpiData data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCharts(bool isWide, DashboardData dashboard) {
    final bookingsChart = _buildBookingsChart(dashboard.monthly);

    final airlineChart = _buildAirlineChart(dashboard.airlines);

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: bookingsChart),
          const SizedBox(width: 20),
          Expanded(child: airlineChart),
        ],
      );
    }

    return Column(
      children: [bookingsChart, const SizedBox(height: 20), airlineChart],
    );
  }

  Widget _buildBookingsChart(List<MonthlyData> monthlyData) {
    if (monthlyData.isEmpty) {
      return _chartCard(
        title: 'Evolución de reservas',
        subtitle: 'Reservas registradas por periodo',
        icon: Icons.bar_chart_rounded,
        child: const SizedBox(
          height: 290,
          child: Center(
            child: Text(
              'No hay información disponible.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ),
      );
    }

    final maxBookings = monthlyData
        .map((item) => item.bookings)
        .reduce((a, b) => a > b ? a : b);

    return _chartCard(
      title: 'Evolución de reservas',
      subtitle: 'Reservas registradas por periodo',
      icon: Icons.bar_chart_rounded,
      child: SizedBox(
        height: 290,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: monthlyData.map((item) {
            final bookings = item.bookings;

            final height = maxBookings == 0
                ? 8.0
                : (bookings / maxBookings) * 190;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatNumber(bookings),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      height: height.clamp(8.0, 190.0).toDouble(),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppTheme.primaryRed, AppTheme.darkRed],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatPeriod(item.period),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAirlineChart(List<AirlineData> airlineData) {
    if (airlineData.isEmpty) {
      return _chartCard(
        title: 'Reservas por aerolínea',
        subtitle: 'Participación según reservas registradas',
        icon: Icons.flight_rounded,
        child: const SizedBox(
          height: 290,
          child: Center(
            child: Text(
              'No hay información disponible.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ),
      );
    }

    final visibleAirlines = airlineData.take(6).toList();

    final maxBookings = visibleAirlines
        .map((item) => item.bookings)
        .reduce((a, b) => a > b ? a : b);

    return _chartCard(
      title: 'Reservas por aerolínea',
      subtitle: 'Participación según reservas registradas',
      icon: Icons.flight_rounded,
      child: SizedBox(
        height: 290,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: visibleAirlines.map((item) {
            final bookings = item.bookings;

            final percentage = maxBookings == 0 ? 0.0 : bookings / maxBookings;

            return Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    item.airline,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.navyBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppTheme.navyBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 58,
                  child: Text(
                    _formatNumber(bookings),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _chartCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: AppTheme.primaryRed, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildOperationalSummary(bool isWide, DashboardData dashboard) {
    final cards = [
      _SummaryData(
        title: 'Vuelos sin reservas',
        value: _formatNumber(dashboard.kpis.flightsWithoutBookings),
        description: 'Vuelos que no registran reservas',
        icon: Icons.flight_land_rounded,
        color: AppTheme.primaryRed,
      ),
      _SummaryData(
        title: 'Conexiones',
        value: _formatNumber(dashboard.kpis.connections),
        description: 'Conexiones aéreas disponibles',
        icon: Icons.route_rounded,
        color: AppTheme.navyBlue,
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map(
              (card) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: card == cards.first ? 10 : 0),
                  child: _summaryCard(card),
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: cards
          .map(
            (card) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _summaryCard(card),
            ),
          )
          .toList(),
    );
  }

  Widget _summaryCard(_SummaryData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(data.icon, color: data.color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: data.color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  String _formatPeriod(String period) {
    if (period.length != 7 || !period.contains('-')) {
      return period;
    }

    final parts = period.split('-');

    if (parts.length != 2) {
      return period;
    }

    const months = {
      '01': 'Ene',
      '02': 'Feb',
      '03': 'Mar',
      '04': 'Abr',
      '05': 'May',
      '06': 'Jun',
      '07': 'Jul',
      '08': 'Ago',
      '09': 'Sep',
      '10': 'Oct',
      '11': 'Nov',
      '12': 'Dic',
    };

    final month = months[parts[1]];

    if (month == null) {
      return period;
    }

    return month;
  }
}

class _KpiData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _SummaryData {
  final String title;
  final String value;
  final String description;
  final IconData icon;
  final Color color;

  const _SummaryData({
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
    required this.color,
  });
}
