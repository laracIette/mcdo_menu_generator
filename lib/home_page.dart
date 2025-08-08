import 'package:flutter/material.dart';
import 'package:mcdo_menu_generator/filters.dart';
import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/items.dart';
import 'package:mcdo_menu_generator/filters_page.dart';
import 'package:mcdo_menu_generator/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> { // todo: check Set
  double targetCalories = 0.0;

  double currentCalories = 0.0;
  double currentPrice = 0.0;

  Filters _filters = Filters();

  List<Item> filteredItems = [];

  void _filterItems() {
    setState(() {
      filteredItems = _filters.requiredItems.toList();
      currentCalories = 0.0;
      currentPrice = 0.0;

      for (var item in filteredItems) {
        currentCalories += item.calories;
        currentPrice += item.price;
      }

      final List<Item> sortedItems = getSortedItems((a, b) => (b.calories.compareTo(a.calories)));

      for (var item in sortedItems) {
        // ignore not allowed item type
        if (!_filters.allowedItemTypes.contains(item.type)) {
          continue;
        }

        // ignore already added required item
        if (_filters.requiredItems.contains(item)) {
          continue;
        }

        // ignore item if total calories too high
        if (currentCalories + item.calories > targetCalories) {
          continue;
        }

        currentCalories += item.calories;
        currentPrice += item.price;

        filteredItems.add(item);
      }
    });
  }

  void _updateTargetCalories(String input) {
    targetCalories = double.tryParse(input) ?? 0.0;
    _filterItems();
  }

  void _openSideSheet(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.3),
        pageBuilder: (context, animation, secondaryAnimation) => FiltersPage(
          animation: animation,
          filters: _filters,
          onFiltersUpdated: (filters) {
            _filters = filters;
            _filterItems();
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
          position: Tween<Offset>(
            begin: Offset(1, 0), // Slide from right
            end: Offset(0, 0),
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
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

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Target Calories',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _updateTargetCalories,
                    ),
                  ),

                  const HorizontalSizedBox(),

                  ElevatedButton(
                    onPressed: () => _openSideSheet(context),
                    child: const Text('Filters'),
                  ),
                ],
              ),

              const VerticalSizedBox(),

              Row(
                children: [
                  Text('Items : ${filteredItems.length}'),
                  Spacer(),
                  Text('Calories : $currentCalories kcal'),
                  Spacer(),
                  Text('Price : $currentPrice €'),
                ]
              ),

              const VerticalSizedBox(),

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

