import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickbite/providers/auth_provider.dart';
import 'package:quickbite/providers/cart_provider.dart';
import 'package:quickbite/providers/menu_provider.dart';
import 'package:quickbite/utils/constants.dart';
import 'package:quickbite/widgets/menu_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('QuickBite Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Consumer3<AuthProvider, MenuProvider, CartProvider>(
        builder: (context, authProvider, menuProvider, cartProvider, _) {
          if (menuProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (menuProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      menuProvider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => menuProvider.loadMenu(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final items = menuProvider.items;
          if (items.isEmpty) {
            return const Center(child: Text('No menu items found.'));
          }

          return RefreshIndicator(
            onRefresh: menuProvider.loadMenu,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return MenuCard(
                  menuItem: item,
                  onAdd: () {
                    cartProvider.addItem(item);
                    final snackBar = SnackBar(
                      content: Text('${item.name} added to cart'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.itemCount == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
            backgroundColor: kAccentColor,
            label: Text(
              '${cartProvider.itemCount} items | ${cartProvider.totalPrice.toStringAsFixed(2)}',
            ),
            icon: const Icon(Icons.shopping_bag),
          );
        },
      ),
    );
  }
}
