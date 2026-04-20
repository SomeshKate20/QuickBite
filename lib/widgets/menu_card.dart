import 'package:flutter/material.dart';
import 'package:quickbite/models/menu_item.dart';
import 'package:quickbite/utils/constants.dart';

class MenuCard extends StatelessWidget {
  final MenuItemModel menuItem;
  final VoidCallback onAdd;

  const MenuCard({super.key, required this.menuItem, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    menuItem.category,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₹${menuItem.price.toStringAsFixed(2)}',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: kAccentColor),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
