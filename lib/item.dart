import 'package:mcdo_menu_generator/item_type.dart';

class Item {
  const Item({required this.id, required this.name, required this.type, required this.calories, required this.price, required this.imagePath});

  final int id;
  final String name;
  final ItemType type;
  final double calories;
  final double price;
  final String imagePath;

  // calories per euro
  double get value => calories / price;

  @override
  bool operator==(Object other) =>
    identical(this, other) ||
    other is Item && id == other.id;

  @override
  int get hashCode => id.hashCode;
}