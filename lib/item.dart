import 'package:mcdo_menu_generator/item_type.dart';

class Item {
  const Item({required this.name, required this.type, required this.calories, required this.price, required this.imagePath});

  final String name;
  final ItemType type;
  final double calories;
  final double price;
  final String imagePath;
}