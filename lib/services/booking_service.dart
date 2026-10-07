import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/booking_model.dart';

class BookingService {
  static const String bookingsUrl =
      'https://gsesrwdcc.santaelena.com.pe:44300/'
      'zflight_analyt/bookings';

  Future<BookingResponse> getBookings({
    required String usuario,
    required String password,
    required String fechaDesde,
    required String fechaHasta,
    String? airline,
    String? connection,
    String? bookingClass,
    String? customerType,
    String? cancelled,
    int pageSize = 20,
    int offset = 0,
  }) async {
    final credentials = base64Encode(utf8.encode('$usuario:$password'));

    final parameters = <String, String>{
      'FLDATE_DESDE': fechaDesde,
      'FLDATE_HASTA': fechaHasta,
      'PAGE_SIZE': pageSize.toString(),
      'OFFSET': offset.toString(),
    };

    if (airline != null && airline.trim().isNotEmpty) {
      parameters['CARRID'] = airline.trim().toUpperCase();
    }

    if (connection != null && connection.trim().isNotEmpty) {
      parameters['CONNID'] = connection.trim();
    }

    if (bookingClass != null && bookingClass.trim().isNotEmpty) {
      parameters['CLASS'] = bookingClass.trim().toUpperCase();
    }

    if (customerType != null && customerType.trim().isNotEmpty) {
      parameters['CUSTTYPE'] = customerType.trim().toUpperCase();
    }

    if (cancelled != null && cancelled.trim().isNotEmpty) {
      parameters['CANCELLED'] = cancelled.trim().toUpperCase();
    }

    final uri = Uri.parse(bookingsUrl).replace(queryParameters: parameters);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Basic $credentials',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      return BookingResponse.fromJson(jsonData);
    }

    if (response.statusCode == 401) {
      throw Exception('Usuario o contraseña incorrectos para SAP.');
    }

    if (response.statusCode == 403) {
      throw Exception('SAP rechazó el acceso al servicio.');
    }

    throw Exception(
      'Error al consultar reservas. '
      'Código HTTP: ${response.statusCode}',
    );
  }
}
