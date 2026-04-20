import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickbite/providers/auth_provider.dart';
import 'package:quickbite/providers/order_provider.dart';
import 'package:quickbite/utils/constants.dart';
import 'package:quickbite/utils/helpers.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.loadOrders(
        userId: authProvider.user?.id ?? '',
        isAdmin: authProvider.user?.email == kAdminEmail,
      );
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('Order Status'),
      ),
      body: Consumer2<AuthProvider, OrderProvider>(
        builder: (context, authProvider, orderProvider, _) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orderProvider.errorMessage != null) {
            return Center(child: Text(orderProvider.errorMessage!));
          }
          final orders = orderProvider.orders;
          if (orders.isEmpty) {
            return const Center(
              child: Text('No orders yet. Place your first order.'),
            );
          }

          final activeOrder = orders.firstWhere(
            (order) => order.status != 'Ready',
            orElse: () => orders.first,
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Order',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Token #: ${activeOrder.tokenNumber}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Status: ${activeOrder.status}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Items: ${activeOrder.items.length}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: activeOrder.items.map((item) {
                            return Chip(
                              label: Text('${item.name} x${item.quantity}'),
                            );
                          }).toList(),
                        ),
                        if (authProvider.user?.email == kAdminEmail) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: activeOrder.status == 'Ready'
                                      ? null
                                      : () async {
                                          final messenger =
                                              ScaffoldMessenger.of(context);
                                          await orderProvider.updateOrderStatus(
                                            activeOrder.id,
                                            'Ready',
                                          );
                                          if (!mounted) return;
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Order marked ready',
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                  child: const Text('Mark Ready'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Order History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            'Token ${order.tokenNumber} • ${order.status}',
                          ),
                          subtitle: Text(
                            '${order.items.length} items • ${Helpers.formatCurrency(order.totalPrice)}',
                          ),
                          trailing: Text(
                            order.timestamp
                                .toLocal()
                                .toString()
                                .split('.')
                                .first,
                          ),
                        ),
                      );
                    },
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
