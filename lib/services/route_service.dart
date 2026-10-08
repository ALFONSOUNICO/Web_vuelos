import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/route_model.dart';

class RouteService {
  static const String baseUrl =
      'https://gsesrwdcc.santaelena.com.pe:44300/zflight_analyt/routes';

  Future<RouteResponse> consultarRutas({
    required String usuario,
    required String password,
    String fechaDesde = '20260401',
    String fechaHasta = '20270531',
    String aerolinea = '',
    String vuelo = '',
    String origen = '',
    String destino = '',
    int pageSize = 20,
    int offset = 0,
  }) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'sap-client': '200',
        'FLDATE_DESDE': fechaDesde,
        'FLDATE_HASTA': fechaHasta,
        'CARRID': aerolinea,
        'CONNID': vuelo,
        'CITYFROM': origen,
        'CITYTO': destino,
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

      return RouteResponse.fromJson(jsonData);
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Usuario o contraseña incorrectos para SAP.',
      );
    }

    throw Exception(
      'Error al consultar rutas. Código HTTP: ${response.statusCode}',
    );
  }
}