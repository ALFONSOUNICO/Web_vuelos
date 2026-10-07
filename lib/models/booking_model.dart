class BookingResponse {
  final int total;
  final int pageSize;
  final int offset;
  final List<BookingData> bookings;
  final String message;

  const BookingResponse({
    required this.total,
    required this.pageSize,
    required this.offset,
    required this.bookings,
    required this.message,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      total: (json['TOTAL'] as num?)?.toInt() ?? 0,
      pageSize: (json['PAGE_SIZE'] as num?)?.toInt() ?? 100,
      offset: (json['OFFSET'] as num?)?.toInt() ?? 0,
      bookings: (json['BOOKINGS'] as List<dynamic>? ?? [])
          .map((item) => BookingData.fromJson(item as Map<String, dynamic>))
          .toList(),
      message: json['MESSAGE']?.toString() ?? '',
    );
  }
}

class BookingData {
  final String bookingId;
  final String airline;
  final String connection;
  final String flightDate;
  final String customerId;
  final String customer;
  final String customerType;
  final String bookingClass;
  final double amount;
  final String currency;
  final String cancelled;

  const BookingData({
    required this.bookingId,
    required this.airline,
    required this.connection,
    required this.flightDate,
    required this.customerId,
    required this.customer,
    required this.customerType,
    required this.bookingClass,
    required this.amount,
    required this.currency,
    required this.cancelled,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      bookingId: json['BOOKID']?.toString() ?? '',
      airline: json['CARRID']?.toString() ?? '',
      connection: json['CONNID']?.toString() ?? '',
      flightDate: _formatDate(json['FLDATE']?.toString() ?? ''),
      customerId: json['CUSTOMID']?.toString() ?? '',
      customer: json['CUSTOMER']?.toString() ?? '',
      customerType: json['CUSTTYPE']?.toString() ?? '',
      bookingClass: json['CLASS']?.toString() ?? '',
      amount: (json['FORCURAM'] as num?)?.toDouble() ?? 0,
      currency: json['FORCURKEY']?.toString() ?? '',
      cancelled: json['CANCELLED']?.toString() ?? '',
    );
  }

  bool get isCancelled => cancelled.trim().toUpperCase() == 'X';

  static String _formatDate(String value) {
    if (value.length == 8) {
      return '${value.substring(6, 8)}/'
          '${value.substring(4, 6)}/'
          '${value.substring(0, 4)}';
    }

    return value;
  }
}
