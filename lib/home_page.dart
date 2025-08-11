import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcdo_menu_generator/filters.dart';
import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/filters_page.dart';
import 'package:mcdo_menu_generator/location.dart';
import 'package:mcdo_menu_generator/locations_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _targetCalories = 0.0;
  double _currentCalories = 0.0;
  double _currentPrice = 0.0;

  Filters _filters = Filters();
  List<Item> filteredItems = [];

  Location _currentLocation = Location(id: 0, name: '', url: '');
  Future<List<Item>> get _itemsFuture => _currentLocation.availableItems;
  List<Item> _availableItems = [];

  void _filterItems() {
    setState(() {
      filteredItems = _filters.requiredItems.toList();
      _currentCalories = 0.0;
      _currentPrice = 0.0;

      for (var item in filteredItems) {
        _currentCalories += item.calories;
        _currentPrice += item.price;
      }

      for (var item in _availableItems) {
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
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: const Color.fromARGB(255, 251, 248, 255),
        systemNavigationBarIconBrightness: Brightness.dark,
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
          title: Text('McDo ${_currentLocation.name}'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 16.0,
              children: [
                Row(
                  spacing: 16.0,
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
                              _filters.requiredItems.retainWhere((item) => _availableItems.contains(item));
                            });
                            _filterItems();
                          },
                        ),
                      ),
                      child: const Text('Location'),
                    ),

                    Spacer(),

                    ElevatedButton(
                      onPressed: () => _openSideSheet(
                        context,
                        const Offset(1, 0),
                        (context, animation, secondaryAnimation) => FiltersPage(
                          animation: animation,
                          availableItems: _availableItems,
                          filters: _filters,
                          onFiltersUpdated: (filters) {
                            _filters = filters;
                            _filterItems();
                          }
                        ),
                      ),
                      child: const Text('Filter'),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Text('Items : ${filteredItems.length}'),
                    Spacer(),
                    Text('Calories : $_currentCalories kcal'),
                    Spacer(),
                    Text('Price : ${_currentPrice.toStringAsFixed(2)} €'),
                  ]
                ),

                FutureBuilder(
                  future: _itemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Expanded(child: Center(child: CircularProgressIndicator()));
                    }
                    else if (snapshot.hasError) {
                      return Expanded(child:Center(child: Text('Error: ${snapshot.error}')));
                    }
                    else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Expanded(child:Center(child: Text('No items found')));
                    }
                    else {
                      _availableItems = snapshot.data!;
                      _availableItems.sort((a, b) => b.calories.compareTo(a.calories));
                      return Expanded(
                        child: ListView(
                          children: [
                            ...filteredItems.map(
                              (item) => Row(
                                key: ValueKey(item.id),
                                spacing: 16.0,
                                children: [
                                  Image.asset(
                                    item.imagePath,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        ),
                                        Text('${item.calories} kcal'),
                                      ],
                                    ),
                                  ),

                                  Text('${item.price.toStringAsFixed(2)} €'),
                                ],
                              )
                            ),
                          ]
                        ),
                      );
                    }
                  },
                ),

                TextField(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

