class CustomerData {
  final String customer;
  final String name;
  final String city;
  final String country;
  final String customerType;
  final int bookings;

  const CustomerData({
    required this.customer,
    required this.name,
    required this.city,
    required this.country,
    required this.customerType,
    required this.bookings,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      customer: (json['CUSTOMID'] ?? json['ID'] ?? '').toString(),
      name: (json['CUSTOMER'] ?? json['NAME'] ?? '').toString(),
      city: (json['CITY'] ?? '').toString(),
      country: (json['COUNTRY'] ?? '').toString(),
      customerType: (json['CUSTTYPE'] ?? '').toString(),
      bookings: _toInt(json['BOOKINGS']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class CustomerResponse {
  final int total;
  final int pageSize;
  final int offset;
  final List<CustomerData> customers;
  final String message;

  const CustomerResponse({
    required this.total,
    required this.pageSize,
    required this.offset,
    required this.customers,
    required this.message,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    final rawCustomers =
        json['CUSTOMERS'] ?? json['customers'] ?? [];

    return CustomerResponse(
      total: _toInt(json['TOTAL']),
      pageSize: _toInt(json['PAGE_SIZE']),
      offset: _toInt(json['OFFSET']),
      customers: (rawCustomers as List)
          .map(
            (item) => CustomerData.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      message: (json['MESSAGE'] ?? json['message'] ?? '').toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}