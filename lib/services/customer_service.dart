import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/customer_model.dart';

class CustomerService {
  static const String baseUrl =
      'https://gsesrwdcc.santaelena.com.pe:44300/zflight_analyt/customers';

  Future<CustomerResponse> consultarClientes({
    required String usuario,
    required String password,
    String pais = '',
    String ciudad = '',
    String tipoCliente = '',
    int pageSize = 20,
    int offset = 0,
  }) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'sap-client': '200',
        'COUNTRY': pais,
        'CITY': ciudad,
        'CUSTTYPE': tipoCliente,
        'PAGE_SIZE': pageSize.toString(),
        'OFFSET': offset.toString(),
      },
    );

    final credentials = base64Encode(
      utf8.encode('$usuario:$password'),
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Basic $credentials',
      },
    );

    if (response.statusCode == 200) {
      final jsonData =
          jsonDecode(response.body) as Map<String, dynamic>;

      return CustomerResponse.fromJson(jsonData);
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Usuario o contraseña incorrectos para SAP.',
      );
    }

    throw Exception(
      'Error al consultar clientes. Código HTTP: ${response.statusCode}',
    );
  }
}