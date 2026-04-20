import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickbite/models/menu_item.dart';
import 'package:quickbite/models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MenuItemModel>> fetchMenuItems() async {
    final menuCollection = _firestore
        .collection('menu')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data()!,
          toFirestore: (value, _) => value,
        );

    final querySnapshot = await menuCollection.orderBy('category').get();
    return querySnapshot.docs
        .map((doc) => MenuItemModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<OrderModel>> fetchOrders({
    String? userId,
    bool admin = false,
  }) async {
    final orderCollection = _firestore
        .collection('orders')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data()!,
          toFirestore: (value, _) => value,
        );

    Query<Map<String, dynamic>> query = orderCollection.orderBy(
      'timestamp',
      descending: true,
    );
    if (!admin && userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<OrderModel> placeOrder(OrderModel order) async {
    final docRef = _firestore.collection('orders').doc();
    final orderWithId = OrderModel(
      id: docRef.id,
      userId: order.userId,
      items: order.items,
      totalPrice: order.totalPrice,
      status: order.status,
      tokenNumber: order.tokenNumber,
      timestamp: order.timestamp,
    );
    await docRef.set(orderWithId.toMap());
    return orderWithId;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
    });
  }
}
