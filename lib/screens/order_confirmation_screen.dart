import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickbite/providers/auth_provider.dart';
import 'package:quickbite/providers/cart_provider.dart';
import 'package:quickbite/providers/order_provider.dart';
import 'package:quickbite/utils/constants.dart';
import 'package:quickbite/utils/helpers.dart';
import 'package:quickbite/widgets/primary_button.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _isSubmitting = false;

  Future<void> _placeOrder() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (authProvider.user == null) {
      Helpers.showSnackbar(context, 'Please login to place an order.');
      return;
    }

    setState(() => _isSubmitting = true);
    final order = await orderProvider.placeOrder(
      userId: authProvider.user!.id,
      cartItems: cartProvider.items.values.toList(),
    );
    setState(() => _isSubmitting = false);

    if (order == null) {
      if (!mounted) return;
      Helpers.showSnackbar(
        context,
        orderProvider.errorMessage ?? 'Order failed.',
      );
      return;
    }

    cartProvider.clear();
    if (!mounted) return;
    Helpers.showSnackbar(
      context,
      'Order confirmed! Token #${order.tokenNumber}',
    );
    Navigator.pushReplacementNamed(context, AppRoutes.orderStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('Order Confirmation'),
      ),
      body: Consumer2<CartProvider, OrderProvider>(
        builder: (context, cartProvider, orderProvider, _) {
          if (cartProvider.itemCount == 0) {
            return const Center(
              child: Text('No items in cart. Add food before confirming.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items.values.elementAt(index);
                      return ListTile(
                        title: Text(item.menuItem.name),
                        subtitle: Text('x${item.quantity}'),
                        trailing: Text(
                          '₹${item.totalPrice.toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Text(
                  'Total: ${Helpers.formatCurrency(cartProvider.totalPrice)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Place Order',
                  loading: _isSubmitting || orderProvider.isLoading,
                  onPressed: _placeOrder,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
