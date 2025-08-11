import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/item_type.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class Location {
  Location({required this.id, required this.name, required this.url});

  final int id;
  final String name;
  final String url;

  late final Future<List<Item>> availableItems = getAvailableItems();

  Future<List<Item>> getAvailableItems() async {

    final url = Uri.parse('https://ws.mcdonalds.fr/api/product/99000336?eatType=EAT_IN&responseGroups=RG.PRODUCT.DEFAULT&responseGroups=RG.PRODUCT.RESTAURANT_STATUS&responseGroups=RG.PRODUCT.PICTURES&responseGroups=RG.PRODUCT.CHOICE_DETAILS&responseGroups=RG.PRODUCT.INGREDIENTS&responseGroups=RG.PRODUCT.NUTRITIONAL_VALUES&responseGroups=RG.PRODUCT.ALLERGENS&responseGroups=RG.PRODUCT.CAPPING&responseGroups=RG.PRODUCT.TIP&restaurantRef=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final choices = data['choices'] as List;

      final List<Item> items = [];

      for (var choice in choices) {
        final products = choice['products'] as List;

        items.addAll(products.map((product) {
          final ref = product['ref'] as String;
          final designation = product['designation'] as String;
          final nultritionalValues = product['nutritionalValues'] as List;
          final cal = nultritionalValues.firstWhere((nut) => nut['ref'] as String == 'CAL');
          final price = product['price'] as double;

          return Item(
            id: int.parse(ref),
            name: designation,
            calories: cal['value'],
            price: price / 150.0,
            type: ItemType.burger,
            imagePath: "assets/images/burger.jpg",
          );
        }));
      }

      return items;
    }

    return [];
  }

  double getDistance() => 0.0;

  @override
  bool operator==(Object other) =>
    identical(this, other) ||
    other is Location && id == other.id;

  @override
  int get hashCode => id.hashCode;
}