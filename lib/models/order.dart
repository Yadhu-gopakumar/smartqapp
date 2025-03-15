import 'dart:convert';

class Order {
  final String id;
  final String orderNo;
  final String itemName;
  final String imageUrl;
  final double price;
  final String status;
  final DateTime dateTime;

  Order({
    required this.id,
    required this.itemName,
    required this.orderNo,
    required this.imageUrl,
    required this.price,
    required this.status,
    required this.dateTime,
  });
  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsData = json['items'];
    if (itemsData is String) {
      itemsData = jsonDecode(itemsData); // Convert JSON string to list
    }

    String itemNames = "Unknown Item";
    if (itemsData is List && itemsData.isNotEmpty) {
      itemNames =
          itemsData.map((item) => item['name'] ?? "Unknown Item").join(", ");
    }

    return Order(
      id: json['id'].toString(),
      itemName: itemNames,
      orderNo: json['order_no'] ?? "N/A",
      imageUrl: "https://via.placeholder.com/150",
      price: double.parse(json['total_amount'].toString()),
      status: json['status'],
      dateTime: DateTime.parse(json['date_time']),
    );
  }
}
