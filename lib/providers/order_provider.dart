import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quickbite/models/cart_item.dart';
import 'package:quickbite/models/order_model.dart';
import 'package:quickbite/services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<OrderModel> orders = [];
  bool isLoading = false;
  String? errorMessage;

  Future<OrderModel?> placeOrder({
    required String userId,
    required List<CartItem> cartItems,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      final orderItems = cartItems
          .map(
            (item) => OrderItem(
              id: item.menuItem.id,
              name: item.menuItem.name,
              quantity: item.quantity,
              price: item.menuItem.price,
            ),
          )
          .toList();
      final totalPrice = cartItems.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      final order = OrderModel(
        id: '',
        userId: userId,
        items: orderItems,
        totalPrice: totalPrice,
        status: 'Preparing',
        tokenNumber: _generateToken(),
        timestamp: DateTime.now(),
      );
      final placedOrder = await _firestoreService.placeOrder(order);
      return placedOrder;
    } catch (error) {
      errorMessage = 'Unable to place order. Please try again later.';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrders({
    required String userId,
    required bool isAdmin,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      orders = await _firestoreService.fetchOrders(
        userId: userId,
        admin: isAdmin,
      );
      errorMessage = null;
    } catch (error) {
      errorMessage = 'Unable to fetch orders. Please refresh.';
      orders = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, status);
      orders = orders.map((order) {
        if (order.id == orderId) {
          return OrderModel(
            id: order.id,
            userId: order.userId,
            items: order.items,
            totalPrice: order.totalPrice,
            status: status,
            tokenNumber: order.tokenNumber,
            timestamp: order.timestamp,
          );
        }
        return order;
      }).toList();
      notifyListeners();
    } catch (error) {
      errorMessage = 'Unable to update order status.';
      notifyListeners();
    }
  }

  int _generateToken() {
    final random = Random();
    return 100 + random.nextInt(900);
  }
}
