import 'package:mcdo_menu_generator/item_type.dart';

class Item {
  final String name;
  final ItemType type;
  final double calories;
  final double price;
  final String imagePath;

  Item({this.name = "", this.type = ItemType.none, this.calories = 0.0, this.price = 0.0, this.imagePath = ""});
}