class Customer {
  final String id;
  final String fullname;
  final String shopName;
  final String saleWholesaleCustomerId;
  final String supirId;
  final String namaSupir;

  Customer({
    required this.id,
    required this.fullname,
    required this.shopName,
    required this.saleWholesaleCustomerId,
    required this.supirId,
    required this.namaSupir,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      fullname: json['fullname'],
      shopName: json['shop_name'],
      saleWholesaleCustomerId: json['sale_wholesale_customer_id'],
      supirId: json['supir_id'],
      namaSupir: json['nama_supir'],
    );
  }
}

class GetCustomerBySupirResponse {
  final String msg;
  final List<Customer> result;

  GetCustomerBySupirResponse({
    required this.msg,
    required this.result,
  });

  factory GetCustomerBySupirResponse.fromJson(Map<String, dynamic> json) {
    return GetCustomerBySupirResponse(
      msg: json['msg'],
      result: (json['result'] as List)
          .map((customerJson) => Customer.fromJson(customerJson))
          .toList(),
    );
  }
}
