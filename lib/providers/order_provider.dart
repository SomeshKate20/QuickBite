import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickbite/models/cart_item.dart';
import 'package:quickbite/models/order_model.dart';
import 'package:quickbite/services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  FirestoreService? _firestoreService;
  List<OrderModel> orders = [];
  bool isLoading = false;
  String? errorMessage;
  bool _firebaseInitialized = false;

  bool get firebaseAvailable => _firebaseInitialized;

  OrderProvider() {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      FirebaseFirestore.instance;
      _firestoreService = FirestoreService();
      _firebaseInitialized = true;
    } catch (e) {
      _firebaseInitialized = false;
      debugPrint('Firebase not available: $e');
    }
  }

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
        (total, item) => total + item.totalPrice,
      );
      final order = OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        items: orderItems,
        totalPrice: totalPrice,
        status: 'Preparing',
        tokenNumber: _generateToken(),
        timestamp: DateTime.now(),
      );

      if (_firebaseInitialized && _firestoreService != null) {
        final placedOrder = await _firestoreService!.placeOrder(order);
        return placedOrder;
      } else {
        // Simulate order placement for development
        await Future.delayed(const Duration(seconds: 2));
        orders.add(order);
        errorMessage = 'Order placed successfully (using mock data)';
        return order;
      }
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

      if (_firebaseInitialized && _firestoreService != null) {
        orders = await _firestoreService!.fetchOrders(
          userId: userId,
          admin: isAdmin,
        );
        errorMessage = null;
      } else {
        // Return mock orders for development
        orders = _getMockOrders(userId);
        errorMessage = 'Using mock data - Firebase not configured';
      }
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
      if (_firebaseInitialized && _firestoreService != null) {
        await _firestoreService!.updateOrderStatus(orderId, status);
      } else {
        // Simulate status update for development
        await Future.delayed(const Duration(seconds: 1));
      }
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

  List<OrderModel> _getMockOrders(String userId) {
    return [
      OrderModel(
        id: 'mock_order_1',
        userId: userId,
        items: [
          OrderItem(
            id: '1',
            name: 'Margherita Pizza',
            quantity: 2,
            price: 12.99,
          ),
          OrderItem(id: '4', name: 'French Fries', quantity: 1, price: 4.99),
        ],
        totalPrice: 30.97,
        status: 'Ready',
        tokenNumber: 123,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      OrderModel(
        id: 'mock_order_2',
        userId: userId,
        items: [
          OrderItem(id: '2', name: 'Chicken Burger', quantity: 1, price: 8.99),
          OrderItem(
            id: '5',
            name: 'Chocolate Milkshake',
            quantity: 1,
            price: 5.99,
          ),
        ],
        totalPrice: 14.98,
        status: 'Preparing',
        tokenNumber: 124,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  int _generateToken() {
    final random = Random();
    return 100 + random.nextInt(900);
  }
}
