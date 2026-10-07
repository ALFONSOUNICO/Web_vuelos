import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';

class BookingsPage extends StatefulWidget {
  final String usuario;
  final String password;

  const BookingsPage({
    super.key,
    required this.usuario,
    required this.password,
  });

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final BookingService _service = BookingService();

  final _airlineController = TextEditingController();
  final _connectionController = TextEditingController();

  DateTime _dateFrom = DateTime(2026, 4, 1);
  DateTime _dateTo = DateTime(2027, 5, 31);

  String _bookingClass = '';
  String _customerType = '';
  String _cancelled = '';

  int _pageSize = 20;
  int _offset = 0;

  BookingResponse? _response;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void dispose() {
    _airlineController.dispose();
    _connectionController.dispose();
    super.dispose();
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

  Future<void> _loadBookings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _service.getBookings(
        usuario: widget.usuario,
        password: widget.password,
        fechaDesde: _sapDate(_dateFrom),
        fechaHasta: _sapDate(_dateTo),
        airline: _airlineController.text,
        connection: _connectionController.text,
        bookingClass: _bookingClass,
        customerType: _customerType,
        cancelled: _cancelled,
        pageSize: _pageSize,
        offset: _offset,
      );

      if (!mounted) return;

      setState(() {
        _response = response;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickDate(bool from) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: from ? _dateFrom : _dateTo,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selected == null) return;

    setState(() {
      if (from) {
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

    _loadBookings();
  }

  void _nextPage() {
    if (_response == null) return;

    if (_offset + _pageSize >= _response!.total) {
      return;
    }

    setState(() {
      _offset += _pageSize;
    });

    _loadBookings();
  }

  void _previousPage() {
    if (_offset == 0) return;

    setState(() {
      _offset -= _pageSize;
      if (_offset < 0) _offset = 0;
    });

    _loadBookings();
  }

  int get _currentPage => (_offset ~/ _pageSize) + 1;

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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 22),
            _filters(),
            const SizedBox(height: 22),
            _results(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryRed,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.confirmation_number_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consulta de reservas',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Consulte y analice las reservas registradas.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _filters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.filter_alt_outlined, color: AppTheme.primaryRed),
              SizedBox(width: 9),
              Text(
                'Filtros de búsqueda',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _dateField(
                'Fecha inicio',
                _displayDate(_dateFrom),
                () => _pickDate(true),
              ),
              _dateField(
                'Fecha fin',
                _displayDate(_dateTo),
                () => _pickDate(false),
              ),
              _textField(_airlineController, 'Aerolínea', 'Ej. LH', 160),
              _textField(
                _connectionController,
                'Número de vuelo',
                'Ej. 0400',
                180,
              ),
              _dropdown('Clase', _bookingClass, const [
                '',
                'Y',
                'C',
                'F',
              ], (v) => setState(() => _bookingClass = v ?? '')),
              _dropdown('Tipo de cliente', _customerType, const [
                '',
                'P',
                'B',
              ], (v) => setState(() => _customerType = v ?? '')),
              _dropdown('Estado', _cancelled, const [
                '',
                'N',
                'X',
              ], (v) => setState(() => _cancelled = v ?? '')),
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
                onPressed: _loading
                    ? null
                    : () {
                        setState(() {
                          _airlineController.clear();
                          _connectionController.clear();
                          _bookingClass = '';
                          _customerType = '';
                          _cancelled = '';
                          _dateFrom = DateTime(2026, 4, 1);
                          _dateTo = DateTime(2027, 5, 31);
                          _offset = 0;
                        });
                        _loadBookings();
                      },
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Limpiar'),
              ),
              const Spacer(),
              const Text(
                'Registros:',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _pageSize,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 20, child: Text('20')),
                  DropdownMenuItem(value: 50, child: Text('50')),
                  DropdownMenuItem(value: 100, child: Text('100')),
                ],
                onChanged: _loading
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _pageSize = value;
                          _offset = 0;
                        });
                        _loadBookings();
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateField(String label, String value, VoidCallback onTap) {
    return SizedBox(
      width: 175,
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
          ),
          child: Text(value),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    String hint,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        onSubmitted: (_) => _search(),
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String?> onChanged,
  ) {
    return SizedBox(
      width: 170,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: values.map((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value.isEmpty ? 'Todos' : value),
          );
        }).toList(),
        onChanged: _loading ? null : onChanged,
      ),
    );
  }

  Widget _results() {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: CircularProgressIndicator(color: AppTheme.primaryRed),
        ),
      );
    }

    if (_error != null) {
      return Text(_error!, style: const TextStyle(color: AppTheme.primaryRed));
    }

    if (_response == null) {
      return const SizedBox.shrink();
    }

    final response = _response!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Resultados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 12),
            Chip(label: Text('${response.total} reservas encontradas')),
          ],
        ),
        const SizedBox(height: 14),
        _table(response),
        const SizedBox(height: 14),
        _pagination(response),
      ],
    );
  }

  Widget _table(BookingResponse response) {
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
            columns: const [
              DataColumn(label: Text('N.º reserva')),
              DataColumn(label: Text('Fecha')),
              DataColumn(label: Text('Aerolínea')),
              DataColumn(label: Text('Vuelo')),
              DataColumn(label: Text('Cliente')),
              DataColumn(label: Text('Clase')),
              DataColumn(label: Text('Tipo')),
              DataColumn(label: Text('Importe')),
              DataColumn(label: Text('Estado')),
            ],
            rows: response.bookings
                .map(
                  (b) => DataRow(
                    cells: [
                      DataCell(
                        Text(
                          b.bookingId,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      DataCell(Text(b.flightDate)),
                      DataCell(
                        Text(
                          b.airline,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataCell(Text(b.connection)),
                      DataCell(
                        Text(b.customer.isEmpty ? b.customerId : b.customer),
                      ),
                      DataCell(Text(b.bookingClass)),
                      DataCell(Text(b.customerType)),
                      DataCell(
                        Text(
                          '${b.amount.toStringAsFixed(2)} '
                          '${b.currency}',
                        ),
                      ),
                      DataCell(_statusChip(b.isCancelled)),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(bool cancelled) {
    return Chip(
      label: Text(cancelled ? 'Cancelada' : 'Confirmada'),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: cancelled ? AppTheme.primaryRed : AppTheme.navyBlue,
      ),
      backgroundColor: cancelled
          ? AppTheme.primaryRed.withValues(alpha: 0.08)
          : AppTheme.navyBlue.withValues(alpha: 0.08),
      side: BorderSide.none,
    );
  }

  Widget _pagination(BookingResponse response) {
    final hasPrevious = _offset > 0;
    final hasNext = _offset + _pageSize < response.total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(
            'Página $_currentPage de $_totalPages',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const Spacer(),
          IconButton(
            onPressed: hasPrevious ? _previousPage : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            onPressed: hasNext ? _nextPage : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
