import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/flight_model.dart';

class FlightService {
  static const String flightsUrl =
      'https://gsesrwdcc.santaelena.com.pe:44300/'
      'zflight_analyt/flights';

  Future<FlightResponse> getFlights({
    required String usuario,
    required String password,
    required String fechaDesde,
    required String fechaHasta,
    String? airline,
    String? connection,
    String? origin,
    String? destination,
    int pageSize = 10,
    int offset = 0,
  }) async {
    final credentials = base64Encode(utf8.encode('$usuario:$password'));

    final queryParameters = <String, String>{
      'FLDATE_DESDE': fechaDesde,
      'FLDATE_HASTA': fechaHasta,
      'PAGE_SIZE': pageSize.toString(),
      'OFFSET': offset.toString(),
    };

    if (airline != null && airline.trim().isNotEmpty) {
      queryParameters['CARRID'] = airline.trim().toUpperCase();
    }

    if (connection != null && connection.trim().isNotEmpty) {
      queryParameters['CONNID'] = connection.trim();
    }

    if (origin != null && origin.trim().isNotEmpty) {
      queryParameters['CITYFROM'] = origin.trim().toUpperCase();
    }

    if (destination != null && destination.trim().isNotEmpty) {
      queryParameters['CITYTO'] = destination.trim().toUpperCase();
    }

    final uri = Uri.parse(flightsUrl).replace(queryParameters: queryParameters);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Basic $credentials',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      return FlightResponse.fromJson(jsonData);
    }

    if (response.statusCode == 401) {
      throw Exception('Usuario o contraseña incorrectos para SAP.');
    }

    if (response.statusCode == 403) {
      throw Exception('SAP rechazó el acceso al servicio.');
    }

    throw Exception(
      'Error al consultar vuelos. '
      'Código HTTP: ${response.statusCode}',
    );
  }
}
