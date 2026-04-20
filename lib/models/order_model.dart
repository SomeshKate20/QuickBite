import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'quantity': quantity, 'price': price};
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalPrice;
  final String status;
  final int tokenNumber;
  final DateTime timestamp;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.tokenNumber,
    required this.timestamp,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    final rawItems = (map['items'] as List<dynamic>?) ?? <dynamic>[];
    final rawTimestamp = map['timestamp'];
    final parsedTimestamp = rawTimestamp is Timestamp
        ? rawTimestamp.toDate()
        : rawTimestamp is DateTime
        ? rawTimestamp
        : DateTime.now();

    return OrderModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      items: rawItems
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'Preparing',
      tokenNumber: (map['tokenNumber'] as num?)?.toInt() ?? 0,
      timestamp: parsedTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'tokenNumber': tokenNumber,
      'timestamp': timestamp,
    };
  }
}
