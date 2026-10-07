import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/airline_model.dart';

class AirlineService {
  static const String airlinesUrl =
      'https://gsesrwdcc.santaelena.com.pe:44300/'
      'zflight_analyt/airlines';

  Future<AirlineResponse> getAirlines({
    required String usuario,
    required String password,
  }) async {
    final credentials = base64Encode(utf8.encode('$usuario:$password'));

    final response = await http.get(
      Uri.parse(airlinesUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Basic $credentials',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      return AirlineResponse.fromJson(jsonData);
    }

    if (response.statusCode == 401) {
      throw Exception('Usuario o contraseña incorrectos para SAP.');
    }

    if (response.statusCode == 403) {
      throw Exception('SAP rechazó el acceso al servicio.');
    }

    throw Exception(
      'Error al consultar aerolíneas. '
      'Código HTTP: ${response.statusCode}',
    );
  }
}
