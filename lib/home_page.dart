import 'package:flutter/material.dart';
import 'package:mcdo_menu_generator/filters.dart';
import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/filters_page.dart';
import 'package:mcdo_menu_generator/location.dart';
import 'package:mcdo_menu_generator/locations_page.dart';
import 'package:mcdo_menu_generator/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> { // todo: check Set
  double _targetCalories = 0.0;

  double _currentCalories = 0.0;
  double _currentPrice = 0.0;

  Filters _filters = Filters();

  List<Item> filteredItems = [];

  Location _currentLocation = Location(id: 0, name: "None");

  void _filterItems() {
    setState(() {
      filteredItems = _filters.requiredItems.toList();
      _currentCalories = 0.0;
      _currentPrice = 0.0;

      for (var item in filteredItems) {
        _currentCalories += item.calories;
        _currentPrice += item.price;
      }

      final List<Item> sortedItems = _currentLocation.getAvailableItems().toList();
      sortedItems.sort((a, b) => b.calories.compareTo(a.calories));

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
        if (_currentCalories + item.calories > _targetCalories) {
          continue;
        }

        _currentCalories += item.calories;
        _currentPrice += item.price;

        filteredItems.add(item);
      }
    });
  }

  void _updateTargetCalories(String input) {
    _targetCalories = double.tryParse(input) ?? 0.0;
    _filterItems();
  }

  void _openSideSheet(BuildContext context, Offset startOffset, RoutePageBuilder pageBuilder) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.3),
        pageBuilder: pageBuilder,
        transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
          position: Tween<Offset>(
            begin: startOffset,
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                    ElevatedButton(
                      onPressed: () => _openSideSheet(
                        context,
                        const Offset(-1, 0),
                        (context, animation, secondaryAnimation) => LocationsPage(
                          animation: animation,
                          currentLocation: _currentLocation,
                          onLocationUpdated: (location) {
                            setState(() {
                              _currentLocation = location;
                              _filters.requiredItems.retainWhere((item) => _currentLocation.getAvailableItems().contains(item));
                            });
                            _filterItems();
                          },
                        ),
                      ),
                      child: const Text('Locations'),
                    ),

                    const HorizontalSizedBox(),

                    Expanded(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Target Calories',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _updateTargetCalories,
                      ),
                    ),

                    const HorizontalSizedBox(),

                    ElevatedButton(
                      onPressed: () => _openSideSheet(
                        context,
                        const Offset(1, 0),
                        (context, animation, secondaryAnimation) => FiltersPage(
                          animation: animation,
                          location: _currentLocation,
                          filters: _filters,
                          onFiltersUpdated: (filters) {
                            _filters = filters;
                            _filterItems();
                          }
                        ),
                      ),
                      child: const Text('Filters'),
                    ),
                  ],
                ),

                const VerticalSizedBox(),

                Row(
                  children: [
                    Text('Items : ${filteredItems.length}'),
                    Spacer(),
                    Text('Calories : $_currentCalories kcal'),
                    Spacer(),
                    Text('Price : $_currentPrice €'),
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
      ),
    );
  }
}

