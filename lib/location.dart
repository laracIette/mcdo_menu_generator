import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/item_type.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class Location {
  Location({required this.id, required this.name});

  //double get distance => 0.0;

  final int id;
  final String name;

  static final String _orderType = 'EAT_IN';

  late final String jsonUrl = 'https://ws.mcdonalds.fr/api/catalog/14/products?eatType=$_orderType&responseGroups=RG.PRODUCT.DEFAULT&responseGroups=RG.PRODUCT.CHOICE_DETAILS&responseGroups=RG.PRODUCT.WORKING_HOURS&responseGroups=RG.PRODUCT.PICTURES&responseGroups=RG.PRODUCT.RESTAURANT_STATUS&responseGroups=RG.PRODUCT.CAPPING&responseGroups=RG.PRODUCT.TIP&responseGroups=RG.PRODUCT.NUTRITIONAL_VALUES&restaurantRef=$id';
  //late final String commanderUrl = 'https://www.mcdonalds.fr/restaurants/$id/commander';

  late final Future<List<Item>> availableItems = getAvailableItems();

  Future<List<Item>> getAvailableItems() async {
    final uri = Uri.parse(jsonUrl);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final products = data as List;

      final List<Item> items = [];

      items.addAll(products.map((product) {
          final ref = product['ref'] as String;
          final designation = product['designation'] as String;
          final nultritionalValues = product['nutritionalValues'] as List;
          final cal = nultritionalValues.firstWhere((nut) => nut['ref'] as String == 'CAL');
          final price = product['price'] as double;
          final imageUrl = product['pictures'][0]['url'] as String;

          return Item(
            id: int.parse(ref),
            name: designation,
            calories: cal['value'],
            price: price / 100.0,
            type: ItemType.burger,
            imagePath: 'https://media.mcdonalds.fr$imageUrl',
          );

      }));
      return items;
    }
    return [];
  }

  @override
  bool operator==(Object other) =>
    identical(this, other) ||
    other is Location && id == other.id;

  @override
  int get hashCode => id.hashCode;
}