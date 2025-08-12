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

  Filters _filters = Filters();

  Location _currentLocation = Location(id: 0, name: '');
  Future<List<Item>> get _availableItemsFuture => _currentLocation.availableItems;

  List<Item> _getFilteredItems(List<Item> availableItems) {
    availableItems.sort((a, b) => b.value.compareTo(a.value));

    final filteredItems = _filters.requiredItems.toList();

    var currentCalories = 0.0;
    for (var item in filteredItems) {
      currentCalories += item.calories;
    }

    for (var item in availableItems) {
      // ignore already added required item
      if (_filters.requiredItems.contains(item)) {
        continue;
      }

      // ignore item if total calories too high
      if (currentCalories + item.calories > _targetCalories) {
        continue;
      }

      currentCalories += item.calories;

      filteredItems.add(item);
    }

    return filteredItems;
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

  void _openLocationsPage(BuildContext context) =>
    _openSideSheet(
      context,
      const Offset(-1, 0),
      (context, animation, secondaryAnimation) => LocationsPage(
        animation: animation,
        currentLocation: _currentLocation,
        onLocationUpdated: (location) => setState(() => _currentLocation = location),
      ),
    );

  void _openFiltersPage(BuildContext context) =>
    _openSideSheet(
      context,
      const Offset(1, 0),
      (context, animation, secondaryAnimation) => FiltersPage(
        animation: animation,
        availableItemsFuture: _availableItemsFuture,
        filters: _filters,
        onFiltersUpdated: (filters) => setState(() =>  _filters = filters),
      ),
    );

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: brightness == Brightness.dark
          ? const Color.fromARGB(255, 19, 19, 24)
          : const Color.fromARGB(255, 251, 248, 255),
        systemNavigationBarIconBrightness: brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      ),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx > 50.0) {
          _openLocationsPage(context);
        }
        else if (details.velocity.pixelsPerSecond.dx < -50.0) {
          _openFiltersPage(context);
        }
      },
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
                      onPressed: () => _openLocationsPage(context),
                      child: const Text('Location'),
                    ),

                    Spacer(),

                    ElevatedButton(
                      onPressed: () => _openFiltersPage(context),
                      child: const Text('Filter')
                    ),
                  ],
                ),

                FutureBuilder(
                  future: _availableItemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting
                      || snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Row(
                        children: [
                          Text('Calories : 0 kcal'),
                          Spacer(),
                          Text('Price : 0.00 €'),
                        ]
                      );
                    }
                    else {
                      final filteredItems = _getFilteredItems(snapshot.data!);

                      var currentCalories = 0.0;
                      var currentPrice = 0.0;
                      for (var item in filteredItems) {
                        currentCalories += item.calories;
                        currentPrice += item.price;
                      }

                      return Row(
                        children: [
                          Text('Calories : $currentCalories kcal'),
                          Spacer(),
                          Text('Price : ${currentPrice.toStringAsFixed(2)} €'),
                        ]
                      );
                    }
                  }
                ),

                Expanded(
                  child: FutureBuilder(
                    future: _availableItemsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No items found'));
                      }
                      else {
                        final filteredItems = _getFilteredItems(snapshot.data!);
                        return ListView(
                          children: [
                            ...filteredItems
                              .map((item) => Row(
                                key: ValueKey(item.id),
                                spacing: 16.0,
                                children: [
                                  Image.network(
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
                              )),
                          ],
                        );
                      }
                    },
                  ),
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
                  onChanged: (input) => setState(() => _targetCalories = double.tryParse(input) ?? 0.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

