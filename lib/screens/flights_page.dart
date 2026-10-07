import 'package:flutter/material.dart';

import '../models/flight_model.dart';
import '../services/flight_service.dart';
import '../theme/app_theme.dart';

class FlightsPage extends StatefulWidget {
  final String usuario;
  final String password;

  const FlightsPage({super.key, required this.usuario, required this.password});

  @override
  State<FlightsPage> createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  final FlightService _flightService = FlightService();

  final TextEditingController _airlineController = TextEditingController();

  final TextEditingController _connectionController = TextEditingController();

  final TextEditingController _originController = TextEditingController();

  final TextEditingController _destinationController = TextEditingController();

  DateTime _dateFrom = DateTime(2026, 4, 1);
  DateTime _dateTo = DateTime(2027, 5, 31);

  int _pageSize = 10;
  int _offset = 0;

  FlightResponse? _response;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  @override
  void dispose() {
    _airlineController.dispose();
    _connectionController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadFlights() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _flightService.getFlights(
        usuario: widget.usuario,
        password: widget.password,
        fechaDesde: _sapDate(_dateFrom),
        fechaHasta: _sapDate(_dateTo),
        airline: _airlineController.text,
        connection: _connectionController.text,
        origin: _originController.text,
        destination: _destinationController.text,
        pageSize: _pageSize,
        offset: _offset,
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

  String _sapDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _displayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _selectDate({required bool isFrom}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: isFrom ? _dateFrom : _dateTo,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      if (isFrom) {
        _dateFrom = selected;
      } else {
        _dateTo = selected;
      }
    });
  }

  void _search() {
    if (_dateFrom.isAfter(_dateTo)) {
      setState(() {
        _error =
            'La fecha de inicio no puede ser posterior '
            'a la fecha de fin.';
      });
      return;
    }

    setState(() {
      _offset = 0;
    });

    _loadFlights();
  }

  void _clearFilters() {
    setState(() {
      _airlineController.clear();
      _connectionController.clear();
      _originController.clear();
      _destinationController.clear();
      _dateFrom = DateTime(2026, 4, 1);
      _dateTo = DateTime(2027, 5, 31);
      _offset = 0;
    });

    _loadFlights();
  }

  void _nextPage() {
    if (_response == null) {
      return;
    }

    if (_offset + _pageSize >= _response!.total) {
      return;
    }

    setState(() {
      _offset += _pageSize;
    });

    _loadFlights();
  }

  void _previousPage() {
    if (_offset == 0) {
      return;
    }

    setState(() {
      _offset -= _pageSize;

      if (_offset < 0) {
        _offset = 0;
      }
    });

    _loadFlights();
  }

  int get _currentPage {
    if (_response == null || _response!.total == 0) {
      return 1;
    }

    return (_offset ~/ _pageSize) + 1;
  }

  int get _totalPages {
    if (_response == null || _response!.total == 0) {
      return 1;
    }

    return (_response!.total + _pageSize - 1) ~/ _pageSize;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1100;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 28 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 22),
                _buildFilters(isWide),
                const SizedBox(height: 22),
                _buildResults(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.flight_rounded, color: Colors.white),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consulta de vuelos',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Consulte vuelos, capacidad y nivel de ocupación.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilters(bool isWide) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.filter_alt_outlined,
                color: AppTheme.primaryRed,
                size: 21,
              ),
              SizedBox(width: 9),
              Text(
                'Filtros de búsqueda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _buildDateField(
                label: 'Fecha inicio',
                value: _displayDate(_dateFrom),
                onTap: () => _selectDate(isFrom: true),
              ),
              _buildDateField(
                label: 'Fecha fin',
                value: _displayDate(_dateTo),
                onTap: () => _selectDate(isFrom: false),
              ),
              _buildTextField(
                controller: _airlineController,
                label: 'Aerolínea',
                hint: 'Ej. LH',
                width: 170,
              ),
              _buildTextField(
                controller: _connectionController,
                label: 'Número de vuelo',
                hint: 'Ej. 0400',
                width: 190,
              ),
              _buildTextField(
                controller: _originController,
                label: 'Origen',
                hint: 'Ej. Frankfurt',
                width: 190,
              ),
              _buildTextField(
                controller: _destinationController,
                label: 'Destino',
                hint: 'Ej. New York',
                width: 190,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _loading ? null : _search,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Consultar'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _loading ? null : _clearFilters,
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Limpiar'),
              ),
              const Spacer(),
              if (isWide)
                Row(
                  children: [
                    const Text(
                      'Registros por página:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _pageSize,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 10, child: Text('10')),
                        DropdownMenuItem(value: 20, child: Text('20')),
                        DropdownMenuItem(value: 50, child: Text('50')),
                        DropdownMenuItem(value: 100, child: Text('100')),
                      ],
                      onChanged: _loading
                          ? null
                          : (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                _pageSize = value;
                                _offset = 0;
                              });

                              _loadFlights();
                            },
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 175,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today_outlined, size: 19),
          ),
          child: Text(
            value,
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        onSubmitted: (_) => _search(),
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }

  Widget _buildResults() {
    if (_loading) {
      return _buildLoading();
    }

    if (_error != null) {
      return _buildError();
    }

    final response = _response;

    if (response == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultSummary(response),
        const SizedBox(height: 14),
        _buildTable(response),
        const SizedBox(height: 14),
        _buildPagination(response),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 260,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryRed),
          SizedBox(height: 16),
          Text(
            'Consultando información de SAP...',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildResultSummary(FlightResponse response) {
    return Row(
      children: [
        const Text(
          'Resultados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${response.total} vuelos encontrados',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryRed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(FlightResponse response) {
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1250),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              headingTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.navyBlue,
              ),
              dataTextStyle: const TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
              ),
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('Fecha')),
                DataColumn(label: Text('Aerolínea')),
                DataColumn(label: Text('Vuelo')),
                DataColumn(label: Text('Origen')),
                DataColumn(label: Text('Destino')),
                DataColumn(label: Text('Aeropuertos')),
                DataColumn(label: Text('Avión')),
                DataColumn(numeric: true, label: Text('Capacidad')),
                DataColumn(numeric: true, label: Text('Pasajeros')),
                DataColumn(numeric: true, label: Text('Disponibles')),
                DataColumn(numeric: true, label: Text('Ocupación')),
                DataColumn(numeric: true, label: Text('Precio')),
              ],
              rows: response.flights.map(_buildDataRow).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(FlightData flight) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            flight.flightDate,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.navyBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              flight.airline,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppTheme.navyBlue,
              ),
            ),
          ),
        ),
        DataCell(Text(flight.connection)),
        DataCell(Text(flight.origin)),
        DataCell(Text(flight.destination)),
        DataCell(
          Text(
            '${flight.departureAirport} → '
            '${flight.arrivalAirport}',
          ),
        ),
        DataCell(Text(flight.planeType)),
        DataCell(Text(flight.capacity.toString())),
        DataCell(Text(flight.occupied.toString())),
        DataCell(Text(flight.available.toString())),
        DataCell(
          Text(
            '${flight.occupancy.toStringAsFixed(1)}%',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: flight.occupancy >= 80
                  ? AppTheme.primaryRed
                  : AppTheme.navyBlue,
            ),
          ),
        ),
        DataCell(
          Text(
            '${flight.price.toStringAsFixed(2)} '
            '${flight.currency}',
          ),
        ),
      ],
    );
  }

  Widget _buildPagination(FlightResponse response) {
    final hasPrevious = _offset > 0;
    final hasNext = _offset + _pageSize < response.total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(
            'Página $_currentPage de $_totalPages',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Página anterior',
            onPressed: hasPrevious && !_loading ? _previousPage : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            tooltip: 'Página siguiente',
            onPressed: hasNext && !_loading ? _nextPage : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
