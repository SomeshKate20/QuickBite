import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickbite/providers/cart_provider.dart';
import 'package:quickbite/utils/constants.dart';
import 'package:quickbite/utils/helpers.dart';
import 'package:quickbite/widgets/primary_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: kPrimaryColor,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.itemCount == 0) {
            return const Center(
              child: Text('Your cart is empty. Add something tasty.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartProvider.items.values.elementAt(
                        index,
                      );
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(cartItem.menuItem.name),
                          subtitle: Text('Quantity: ${cartItem.quantity}'),
                          trailing: Text(
                            '₹${cartItem.totalPrice.toStringAsFixed(2)}',
                          ),
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => cartProvider.decrementItem(
                                  cartItem.menuItem.id,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () =>
                                    cartProvider.addItem(cartItem.menuItem),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total: ${Helpers.formatCurrency(cartProvider.totalPrice)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Confirm Order',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.orderConfirmation,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
