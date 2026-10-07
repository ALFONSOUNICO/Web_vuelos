import 'package:flutter/material.dart';

import '../models/airline_model.dart';
import '../services/airline_service.dart';
import '../theme/app_theme.dart';

class AirlinesPage extends StatefulWidget {
  final String usuario;
  final String password;

  const AirlinesPage({
    super.key,
    required this.usuario,
    required this.password,
  });

  @override
  State<AirlinesPage> createState() => _AirlinesPageState();
}

class _AirlinesPageState extends State<AirlinesPage> {
  final AirlineService _service = AirlineService();

  AirlineResponse? _response;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAirlines();
  }

  Future<void> _loadAirlines() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _service.getAirlines(
        usuario: widget.usuario,
        password: widget.password,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _response = response;
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
    return Container(
      color: AppTheme.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 22),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryRed,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.business_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Análisis de aerolíneas',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Indicadores operativos y comportamiento por aerolínea.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Actualizar',
          onPressed: _loading ? null : _loadAirlines,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(80),
          child: CircularProgressIndicator(color: AppTheme.primaryRed),
        ),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_response == null || _response!.airlines.isEmpty) {
      return const Center(
        child: Text('No se encontraron datos de aerolíneas.'),
      );
    }

    return _buildAirlines(_response!.airlines);
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppTheme.primaryRed),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirlines(List<AirlineData> airlines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Aerolíneas activas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Chip(label: Text('${airlines.length} aerolíneas')),
          ],
        ),
        const SizedBox(height: 16),
        _buildCards(airlines),
        const SizedBox(height: 20),
        _buildTable(airlines),
      ],
    );
  }

  Widget _buildCards(List<AirlineData> airlines) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: airlines.map((airline) {
        return SizedBox(width: 245, child: _buildAirlineCard(airline));
      }).toList(),
    );
  }

  Widget _buildAirlineCard(AirlineData airline) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
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
                width: 46,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.navyBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  airline.airline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${airline.occupancy.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: airline.occupancy >= 80
                      ? AppTheme.primaryRed
                      : AppTheme.navyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${airline.flights} vuelos',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${airline.bookings} reservas',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: airline.occupancy / 100,
            minHeight: 7,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: const Color(0xFFE8EDF2),
            color: airline.occupancy >= 80
                ? AppTheme.primaryRed
                : AppTheme.navyBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<AirlineData> airlines) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.navyBlue,
              fontSize: 12,
            ),
            columns: const [
              DataColumn(label: Text('Aerolínea')),
              DataColumn(numeric: true, label: Text('Vuelos')),
              DataColumn(numeric: true, label: Text('Reservas')),
              DataColumn(numeric: true, label: Text('Ocupación')),
              DataColumn(numeric: true, label: Text('Cancelaciones')),
            ],
            rows: airlines.map((airline) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      airline.airline,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  DataCell(Text(airline.flights.toString())),
                  DataCell(Text(airline.bookings.toString())),
                  DataCell(
                    Text(
                      '${airline.occupancy.toStringAsFixed(2)}%',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  DataCell(Text(airline.cancellations.toString())),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
