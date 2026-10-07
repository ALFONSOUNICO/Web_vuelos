import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'airlines_page.dart';
import 'bookings_page.dart';
import 'dashboard_page.dart';
import 'flights_page.dart';

class AppShell extends StatefulWidget {
  final String usuario;
  final String password;

  const AppShell({super.key, required this.usuario, required this.password});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<String> _titles = const [
    'Dashboard',
    'Vuelos',
    'Reservas',
    'Aerolíneas',
    'Rutas',
    'Clientes',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.flight_takeoff_rounded, size: 25),
                const SizedBox(width: 10),
                Text(_titles[_selectedIndex]),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_done_outlined, size: 17),
                        SizedBox(width: 7),
                        Text(
                          'SAP conectado',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          drawer: isWide ? null : _buildDrawer(context),
          body: Row(
            children: [
              if (isWide) _buildNavigationRail(),
              Expanded(child: _buildCurrentPage()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationRail() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: NavigationRail(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        extended: MediaQuery.of(context).size.width >= 1200,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primaryRed.withValues(alpha: 0.10),
        selectedIconTheme: const IconThemeData(color: AppTheme.primaryRed),
        selectedLabelTextStyle: const TextStyle(
          color: AppTheme.primaryRed,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedIconTheme: const IconThemeData(color: AppTheme.navyBlue),
        unselectedLabelTextStyle: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flight_rounded, color: Colors.white),
          ),
        ),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: Text('Dashboard'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.flight_outlined),
            selectedIcon: Icon(Icons.flight_rounded),
            label: Text('Vuelos'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number_rounded),
            label: Text('Reservas'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business_rounded),
            label: Text('Aerolíneas'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route_rounded),
            label: Text('Rutas'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: Text('Clientes'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 42, 20, 24),
            color: AppTheme.navyBlue,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.flight_takeoff_rounded,
                  color: Colors.white,
                  size: 34,
                ),
                SizedBox(height: 12),
                Text(
                  'SAP Flight Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Centro de análisis de operaciones',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: List.generate(
                _titles.length,
                (index) => ListTile(
                  selected: _selectedIndex == index,
                  selectedTileColor: AppTheme.primaryRed.withValues(
                    alpha: 0.08,
                  ),
                  leading: Icon(
                    _getIcon(index),
                    color: _selectedIndex == index
                        ? AppTheme.primaryRed
                        : AppTheme.navyBlue,
                  ),
                  title: Text(
                    _titles[index],
                    style: TextStyle(
                      color: _selectedIndex == index
                          ? AppTheme.primaryRed
                          : AppTheme.textPrimary,
                      fontWeight: _selectedIndex == index
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _onDestinationSelected(index);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard_outlined;
      case 1:
        return Icons.flight_outlined;
      case 2:
        return Icons.confirmation_number_outlined;
      case 3:
        return Icons.business_outlined;
      case 4:
        return Icons.route_outlined;
      case 5:
        return Icons.people_outline_rounded;
      default:
        return Icons.dashboard_outlined;
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardPage(
          usuario: widget.usuario,
          password: widget.password,
        );

      case 1:
        return FlightsPage(usuario: widget.usuario, password: widget.password);

      case 2:
        return BookingsPage(usuario: widget.usuario, password: widget.password);

      case 3:
        return AirlinesPage(usuario: widget.usuario, password: widget.password);

      case 4:
        return _buildComingSoon(
          Icons.route_outlined,
          'Rutas',
          'Análisis de conexiones y rutas aéreas.',
        );

      case 5:
        return _buildComingSoon(
          Icons.people_outline_rounded,
          'Clientes',
          'Consulta de clientes y comportamiento de reservas.',
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildComingSoon(IconData icon, String title, String description) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: AppTheme.primaryRed, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            const Chip(label: Text('Módulo en desarrollo')),
          ],
        ),
      ),
    );
  }
}
