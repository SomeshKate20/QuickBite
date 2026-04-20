import 'package:flutter/material.dart';
import 'package:quickbite/models/cart_item.dart';
import 'package:quickbite/models/menu_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;

  double get totalPrice {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(MenuItemModel menuItem) {
    if (_items.containsKey(menuItem.id)) {
      _items[menuItem.id]!.quantity += 1;
    } else {
      _items[menuItem.id] = CartItem(menuItem: menuItem, quantity: 1);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void decrementItem(String id) {
    if (!_items.containsKey(id)) return;
    final item = _items[id]!;
    if (item.quantity > 1) {
      item.quantity -= 1;
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
