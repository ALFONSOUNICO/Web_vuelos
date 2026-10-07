import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/dashboard_model.dart';

class SapService {
  static const String dashboardUrl =
      'https://gsesrwdcc.santaelena.com.pe:44300/zflight_analyt/dashboard';

  Future<DashboardData> getDashboard({
    String? usuario,
    String? password,
  }) async {
    final uri = Uri.parse(dashboardUrl);

    final headers = <String, String>{'Accept': 'application/json'};

    // Las credenciales se reciben en tiempo de ejecución.
    // Nunca se almacenan dentro del código fuente.
    if (usuario != null &&
        usuario.isNotEmpty &&
        password != null &&
        password.isNotEmpty) {
      final credentials = base64Encode(utf8.encode('$usuario:$password'));

      headers['Authorization'] = 'Basic $credentials';
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      return DashboardData.fromJson(jsonData);
    }

    if (response.statusCode == 401) {
      throw Exception('Usuario o contraseña incorrectos para SAP.');
    }

    if (response.statusCode == 403) {
      throw Exception(
        'SAP rechazó el acceso al servicio. Verifique las autorizaciones.',
      );
    }

    throw Exception(
      'Error al consultar SAP. Código HTTP: ${response.statusCode}',
    );
  }
}
