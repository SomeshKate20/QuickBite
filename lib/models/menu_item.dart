class MenuItemModel {
  final String id;
  final String name;
  final String category;
  final double price;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuItemModel(
      id: id,
      name: map['name'] as String? ?? 'Unknown',
      category: map['category'] as String? ?? 'General',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'category': category, 'price': price};
  }
}
