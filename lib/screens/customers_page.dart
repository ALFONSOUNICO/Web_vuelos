import 'package:flutter/material.dart';

import '../models/customer_model.dart';
import '../services/customer_service.dart';
import '../theme/app_theme.dart';

class CustomersPage extends StatefulWidget {
  final String usuario;
  final String password;

  const CustomersPage({
    super.key,
    required this.usuario,
    required this.password,
  });

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final CustomerService _service = CustomerService();

  final TextEditingController _countryController =
      TextEditingController();

  final TextEditingController _cityController =
      TextEditingController();

  final TextEditingController _typeController =
      TextEditingController();

  CustomerResponse? _response;

  bool _loading = false;
  String? _errorMessage;

  int _pageSize = 20;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _consultar();
  }

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _consultar() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.consultarClientes(
        usuario: widget.usuario,
        password: widget.password,
        pais: _countryController.text.trim(),
        ciudad: _cityController.text.trim(),
        tipoCliente: _typeController.text.trim(),
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
        _errorMessage = e.toString();
      });
    }
  }

  void _buscar() {
    setState(() {
      _offset = 0;
    });

    _consultar();
  }

  void _limpiarFiltros() {
    _countryController.clear();
    _cityController.clear();
    _typeController.clear();

    setState(() {
      _offset = 0;
    });

    _consultar();
  }

  void _paginaAnterior() {
    if (_offset == 0) return;

    setState(() {
      _offset = (_offset - _pageSize).clamp(0, 999999999);
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

  int get _paginaActual {
    if (_response == null || _response!.total == 0) {
      return 0;
    }

    return (_offset ~/ _pageSize) + 1;
  }

  int get _totalPaginas {
    final total = _response?.total ?? 0;

    if (total == 0) {
      return 0;
    }

    return (total / _pageSize).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final response = _response;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildFilters(),
            const SizedBox(height: 20),
            if (_loading)
              const LinearProgressIndicator()
            else if (_errorMessage != null)
              _buildError()
            else if (response != null)
              _buildResults(response),
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
            color: AppTheme.primaryRed.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.people_alt_outlined,
            color: AppTheme.primaryRed,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clientes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Consulta y análisis de clientes con reservas',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  color: AppTheme.navyBlue,
                ),
                SizedBox(width: 8),
                Text(
                  'Filtros de consulta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 850;

                if (wide) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _countryController,
                          label: 'País',
                          hint: 'Ej. DE',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _cityController,
                          label: 'Ciudad',
                          hint: 'Ej. Walldorf',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _typeController,
                          label: 'Tipo de cliente',
                          hint: 'Ej. P o B',
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildPageSizeField(),
                      const SizedBox(width: 12),
                      _buildActionButtons(),
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _countryController,
                            label: 'País',
                            hint: 'Ej. DE',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'Ciudad',
                            hint: 'Ej. Walldorf',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _typeController,
                            label: 'Tipo de cliente',
                            hint: 'Ej. P o B',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPageSizeField(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildActionButtons(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _buscar(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }

  Widget _buildPageSizeField() {
    return SizedBox(
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

          _consultar();
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: _loading ? null : _buscar,
          icon: const Icon(Icons.search),
          label: const Text('Consultar'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: _loading ? null : _limpiarFiltros,
          icon: const Icon(Icons.clear),
          label: const Text('Limpiar'),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.primaryRed,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage ?? 'Se produjo un error.',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(CustomerResponse response) {
    final customers = response.customers;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.table_chart_outlined,
                  color: AppTheme.navyBlue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Resultados',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: ${response.total}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (customers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'No se encontraron clientes para los filtros seleccionados.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              )
            else
              _buildTable(customers),
            const SizedBox(height: 18),
            _buildPagination(response),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<CustomerData> customers) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                AppTheme.navyBlue.withValues(alpha: 0.06),
              ),
              columnSpacing: 28,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.navyBlue,
              ),
              dataTextStyle: const TextStyle(
                color: AppTheme.textPrimary,
              ),
              columns: const [
                DataColumn(
                  label: Text('Cliente'),
                ),
                DataColumn(
                  label: Text('Nombre'),
                ),
                DataColumn(
                  label: Text('Ciudad'),
                ),
                DataColumn(
                  label: Text('País'),
                ),
                DataColumn(
                  label: Text('Tipo'),
                ),
                DataColumn(
                  numeric: true,
                  label: Text('Reservas'),
                ),
              ],
              rows: customers.map((customer) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        customer.customer,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(Text(customer.name)),
                    DataCell(Text(customer.city)),
                    DataCell(Text(customer.country)),
                    DataCell(_buildTypeBadge(customer.customerType)),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          customer.bookings.toString(),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.navyBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type.isEmpty ? '-' : type,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.navyBlue,
        ),
      ),
    );
  }

  Widget _buildPagination(CustomerResponse response) {
    final canPrevious = _offset > 0;
    final canNext = _offset + _pageSize < response.total;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          response.total == 0
              ? 'Sin registros'
              : 'Página $_paginaActual de $_totalPaginas',
          style: const TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Página anterior',
          onPressed: canPrevious && !_loading
              ? _paginaAnterior
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Página siguiente',
          onPressed: canNext && !_loading
              ? _paginaSiguiente
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}