import 'package:flutter/material.dart';
import 'package:quickbite/models/menu_item.dart';
import 'package:quickbite/services/firestore_service.dart';

class MenuProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<MenuItemModel> items = [];
  bool isLoading = false;
  String? errorMessage;

  MenuProvider() {
    loadMenu();
  }

  Future<void> loadMenu() async {
    try {
      isLoading = true;
      notifyListeners();
      items = await _firestoreService.fetchMenuItems();
      errorMessage = null;
    } catch (error) {
      errorMessage = 'Unable to load menu items. Please check your connection.';
      items = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
