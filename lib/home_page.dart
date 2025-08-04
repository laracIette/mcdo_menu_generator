import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/item_type.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> { // todo: check Set
  double targetCalories = 0.0;

  double currentCalories = 0.0;
  double currentPrice = 0.0;

  static final List<Item> items = [ 
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
  ];

  List<Item> filteredItems = [];

  Map<ItemType, int> itemTypeCounts = {
    ItemType.burger: 0,
    ItemType.nuggets: 0,
    ItemType.salad: 0,
  };

  void filterItems() {
    setState(() {
      filteredItems = [];
      
      currentCalories = 0.0;
      currentPrice = 0.0;
      
      items.sort((a, b) => (b.calories.compareTo(a.calories))); // sort in query function directly
      
      for (var item in items) {
        if (filteredItems.where((filteredItem) => (filteredItem.type == item.type)).length >= (itemTypeCounts[item.type] ?? 0)) {
          continue;
        }
      
        if (currentCalories + item.calories > targetCalories) {
          continue;
        }
      
        currentCalories += item.calories;
        currentPrice += item.price;
      
        filteredItems.add(item);
      }
    });
  }

  void updateTargetCalories(String input) {
    targetCalories = double.tryParse(input) ?? 0.0;
    filterItems();
  }

  void setItemTypeCount(ItemType itemType, int count) {
    itemTypeCounts[itemType] = count;
    filterItems();
  }

  void decrementItemTypeCount(ItemType itemType) {
    setItemTypeCount(itemType, max(0, (itemTypeCounts[itemType] ?? 0) - 1));
  }

  void incrementItemTypeCount(ItemType itemType) {
    setItemTypeCount(itemType, min((itemTypeCounts[itemType] ?? 0) + 1, items.where((item) => (item.type == itemType)).length));
  }

  Widget getItemTypeButton(ItemType itemType) {
    const Map<ItemType, String> names = {
      ItemType.burger: 'Burgers',
      ItemType.nuggets: 'Nuggets',
      ItemType.salad: 'Salads',
    };

    return Row(
      children: [
        ElevatedButton(
          onPressed: () => decrementItemTypeCount(itemType),
          child: Text('-'),
        ),

        Text('${names[itemType]}: ${itemTypeCounts[itemType]}'),

        ElevatedButton(
          onPressed: () => incrementItemTypeCount(itemType),
          child: Text('+'),
        ),
      ],
    );
  }

  Widget getSizedBox() {
    return const SizedBox(height: 32.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              TextField(
                decoration: InputDecoration(
                  labelText: 'Target Calories',
                  border: OutlineInputBorder(),
                ),
                onChanged: updateTargetCalories
              ),

              getSizedBox(),

              Row(
                children: [
                  getItemTypeButton(ItemType.burger),
                  Spacer(),
                  getItemTypeButton(ItemType.nuggets),
                  Spacer(),
                  getItemTypeButton(ItemType.salad),
                ],
              ),

              getSizedBox(),
             
              Row(
                children: [
                  Text('Items : ${filteredItems.length}'),
                  Spacer(),
                  Text('Calories : $currentCalories kcal'),
                  Spacer(),
                  Text('Price : $currentPrice €'),
                ]
              ),

              getSizedBox(),

              Expanded(
                child: ListView(
                  children: [
                    ...filteredItems.map(
                      (item) => Row(
                        key: ValueKey(item.name),
                        children: [
                          Image.asset(
                            item.imagePath,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover, 
                          ),
                          Spacer(),
                          Column(
                            children: [
                              Text(item.name),
                              Text('${item.calories} kcal'),
                            ],
                          ),
                          Spacer(),
                          Text('${item.price} €'),
                        ],
                      )
                    ),
                  ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}