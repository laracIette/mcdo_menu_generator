import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/item_type.dart';

const Set<Item> items = {
  Item(name: "Big Mac", type: ItemType.burger, calories: 530.0, price: 7.0, imagePath: "assets/images/burger.jpg"),
  Item(name: "Shrimp Filet", type: ItemType.burger, calories: 443.0, price: 6.5, imagePath: "assets/images/burger.jpg"),
  Item(name: "Teriyaki Chicken", type: ItemType.burger, calories: 468.0, price: 8.0, imagePath: "assets/images/burger.jpg"),
  Item(name: "Filet-O-Fish", type: ItemType.burger, calories: 329.0, price: 6.0, imagePath: "assets/images/burger.jpg"),
  Item(name: "Croque McDo", type: ItemType.burger, calories: 255.0, price: 4.5, imagePath: "assets/images/burger.jpg"),
  Item(name: "Cheeseburger", type: ItemType.burger, calories: 300.0, price: 3.5, imagePath: "assets/images/burger.jpg"),
  Item(name: "Big Arch", type: ItemType.burger, calories: 1076.0, price: 9.5, imagePath: "assets/images/burger.jpg"),
  Item(name: "4 McNuggets", type: ItemType.nuggets, calories: 180.0, price: 3.0, imagePath: "assets/images/nuggets.png"),
  Item(name: "6 McNuggets", type: ItemType.nuggets, calories: 270.0, price: 4.0, imagePath: "assets/images/nuggets.png"),
  Item(name: "9 McNuggets", type: ItemType.nuggets, calories: 405.0, price: 5.0, imagePath: "assets/images/nuggets.png"),
  Item(name: "20 McNuggets", type: ItemType.nuggets, calories: 900.0, price: 10.0, imagePath: "assets/images/nuggets.png"),
  Item(name: "Salad", type: ItemType.salad, calories: 400.0, price: 10.0, imagePath: "assets/images/salad.jpg"),
};

List<Item> getSortedItems(int Function(Item, Item) function) {
  List<Item> sortedItems = items.toList();
  return sortedItems..sort(function);
}