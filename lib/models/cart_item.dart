import 'package:quickbite/models/menu_item.dart';

class CartItem {
  final MenuItemModel menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});

  double get totalPrice => menuItem.price * quantity;
}
