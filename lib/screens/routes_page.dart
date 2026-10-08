import 'package:flutter/material.dart';

import '../models/route_model.dart';
import '../services/route_service.dart';
import '../theme/app_theme.dart';

class RoutesPage extends StatefulWidget {
  final String usuario;
  final String password;

  const RoutesPage({
    super.key,
    required this.usuario,
    required this.password,
  });

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  final RouteService _service = RouteService();

  final _aerolineaController = TextEditingController();
  final _vueloController = TextEditingController();
  final _origenController = TextEditingController();
  final _destinoController = TextEditingController();

  DateTime _fechaDesde = DateTime(2026, 4, 1);
  DateTime _fechaHasta = DateTime(2027, 5, 31);

  int _pageSize = 20;
  int _offset = 0;

  bool _loading = false;
  String? _error;

  RouteResponse? _response;

  @override
  void initState() {
    super.initState();
    _consultar();
  }

  @override
  void dispose() {
    _aerolineaController.dispose();
    _vueloController.dispose();
    _origenController.dispose();
    _destinoController.dispose();
    super.dispose();
  }

  Future<void> _consultar() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.consultarRutas(
        usuario: widget.usuario,
        password: widget.password,
        fechaDesde: _formatDate(_fechaDesde),
        fechaHasta: _formatDate(_fechaHasta),
        aerolinea: _aerolineaController.text.trim().toUpperCase(),
        vuelo: _vueloController.text.trim(),
        origen: _origenController.text.trim().toUpperCase(),
        destino: _destinoController.text.trim().toUpperCase(),
        pageSize: _pageSize,
        offset: _offset,
      );

      if (!mounted) return;

      setState(() {
        _response = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _seleccionarFecha(bool desde) async {
    final actual = desde ? _fechaDesde : _fechaHasta;

    final seleccionada = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (seleccionada == null) return;

    setState(() {
      if (desde) {
        _fechaDesde = seleccionada;
      } else {
        _fechaHasta = seleccionada;
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _displayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatNumber(num value) {
    return value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }

  void _nuevaConsulta() {
    setState(() {
      _offset = 0;
    });

    _consultar();
  }

  void _paginaAnterior() {
    if (_offset == 0) return;

    setState(() {
      _offset = (_offset - _pageSize).clamp(0, _response?.total ?? 0);
    });

    _consultar();
  }

  void _paginaSiguiente() {
    final total = _response?.total ?? 0;

    if (_offset + _pageSize >= total) return;

    setState(() {
      _offset += _pageSize;
    });

    _consultar();
  }

  @override
  Widget build(BuildContext context) {
    final response = _response;
    final total = response?.total ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consulta de rutas',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Análisis de conexiones y rutas aéreas.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 22),
          _buildFilters(),
          const SizedBox(height: 20),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            _buildError()
          else if (response != null)
            _buildResults(response, total),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 14,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            _dateField(
              'Fecha inicio',
              _displayDate(_fechaDesde),
              () => _seleccionarFecha(true),
            ),
            _dateField(
              'Fecha fin',
              _displayDate(_fechaHasta),
              () => _seleccionarFecha(false),
            ),
            _textField(
              _aerolineaController,
              'Aerolínea',
              width: 150,
            ),
            _textField(
              _vueloController,
              'Número de vuelo',
              width: 160,
            ),
            _textField(
              _origenController,
              'Origen',
              width: 150,
            ),
            _textField(
              _destinoController,
              'Destino',
              width: 150,
            ),
            SizedBox(
              width: 130,
              child: DropdownButtonFormField<int>(
                initialValue: _pageSize,
                decoration: const InputDecoration(
                  labelText: 'Registros',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 10,
                    child: Text('10'),
                  ),
                  DropdownMenuItem(
                    value: 20,
                    child: Text('20'),
                  ),
                  DropdownMenuItem(
                    value: 50,
                    child: Text('50'),
                  ),
                  DropdownMenuItem(
                    value: 100,
                    child: Text('100'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _pageSize = value;
                    _offset = 0;
                  });
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: _nuevaConsulta,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Consultar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: 155,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          child: Text(value),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.primaryRed,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: _consultar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(
    RouteResponse response,
    int total,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.route_rounded,
                  color: AppTheme.primaryRed,
                ),
                const SizedBox(width: 10),
                Text(
                  '${_formatNumber(total)} rutas encontradas',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (response.routes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    'No existen rutas para los filtros indicados.',
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(
                    const Color(0xFFF1F5F9),
                  ),
                  columns: const [
                    DataColumn(label: Text('Ruta')),
                    DataColumn(label: Text('N.º vuelo')),
                    DataColumn(label: Text('Aerolínea')),
                    DataColumn(label: Text('Vuelos')),
                    DataColumn(label: Text('Reservas')),
                    DataColumn(label: Text('Duración')),
                    DataColumn(label: Text('Distancia')),
                    DataColumn(label: Text('Ocupación')),
                  ],
                  rows: response.routes.map((route) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            '${route.origin} → ${route.destination}',
                          ),
                        ),
                        DataCell(Text(route.flight)),
                        DataCell(
                          Text(
                            route.airline,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(_formatNumber(route.flights)),
                        ),
                        DataCell(
                          Text(_formatNumber(route.bookings)),
                        ),
                        DataCell(
                          Text('${route.duration} min'),
                        ),
                        DataCell(
                          Text(
                            '${route.distance.toStringAsFixed(0)} '
                            '${route.distanceUnit}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${route.occupancy.toStringAsFixed(2)}%',
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 18),
            _buildPagination(response),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(RouteResponse response) {
    final from = response.total == 0
        ? 0
        : response.offset + 1;

    final to = (response.offset + response.routes.length)
        .clamp(0, response.total);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$from - $to de ${response.total}',
          style: const TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Página anterior',
          onPressed: response.offset > 0
              ? _paginaAnterior
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Página siguiente',
          onPressed:
              response.offset + response.pageSize < response.total
                  ? _paginaSiguiente
                  : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}