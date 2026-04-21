import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickbite/models/menu_item.dart';
import 'package:quickbite/services/firestore_service.dart';

class MenuProvider extends ChangeNotifier {
  FirestoreService? _firestoreService;
  List<MenuItemModel> items = [];
  bool isLoading = false;
  String? errorMessage;
  bool _firebaseInitialized = false;

  bool get firebaseAvailable => _firebaseInitialized;

  MenuProvider() {
    _initializeFirebase();
    loadMenu();
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

  Future<void> loadMenu() async {
    try {
      isLoading = true;
      notifyListeners();

      if (_firebaseInitialized && _firestoreService != null) {
        items = await _firestoreService!.fetchMenuItems();
        errorMessage = null;
      } else {
        // Provide mock data for development
        items = _getMockMenuItems();
        errorMessage = 'Using mock data - Firebase not configured';
      }
    } catch (error) {
      errorMessage = 'Unable to load menu items. Please check your connection.';
      items = _getMockMenuItems(); // Fallback to mock data
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<MenuItemModel> _getMockMenuItems() {
    return [
      MenuItemModel(
        id: '1',
        name: 'Margherita Pizza',
        category: 'Pizza',
        price: 12.99,
      ),
      MenuItemModel(
        id: '2',
        name: 'Chicken Burger',
        category: 'Burgers',
        price: 8.99,
      ),
      MenuItemModel(
        id: '3',
        name: 'Caesar Salad',
        category: 'Salads',
        price: 7.99,
      ),
      MenuItemModel(
        id: '4',
        name: 'French Fries',
        category: 'Sides',
        price: 4.99,
      ),
      MenuItemModel(
        id: '5',
        name: 'Chocolate Milkshake',
        category: 'Drinks',
        price: 5.99,
      ),
    ];
  }
}
