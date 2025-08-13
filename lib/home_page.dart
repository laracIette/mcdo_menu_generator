import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcdo_menu_generator/filters.dart';
import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/filters_page.dart';
import 'package:mcdo_menu_generator/locations_page.dart';
import 'package:mcdo_menu_generator/shared_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _targetCalories = 0.0;

  Filters get _filters => sharedData.filters;

  int _randomSeed = 0;
  bool _isRandom = false;

  List<Item> _getFilteredItems(List<Item> availableItems) {
    final myAvailableItems = List<Item>.from(availableItems);
    if (_isRandom) {
      myAvailableItems.shuffle(Random(_randomSeed));
    }
    else {
      myAvailableItems.sort((a, b) => b.value.compareTo(a.value));
    }

    final filteredItems = _filters.requiredItems.toList();

    var currentCalories = 0.0;
    for (var item in filteredItems) {
      currentCalories += item.calories;
    }

    for (var item in myAvailableItems) {
      // ignore already added required item
      if (_filters.requiredItems.contains(item)) {
        continue;
      }

      // ignore excluded item
      if (_filters.excludedItems.contains(item)) {
        continue;
      }

      // ignore item if total calories too high
      if (currentCalories + item.calories > _targetCalories * 1.05) {
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
        onPop: () => setState(() {}),
      ),
    );

  void _openFiltersPage(BuildContext context) =>
    _openSideSheet(
      context,
      const Offset(1, 0),
      (context, animation, secondaryAnimation) => FiltersPage(
        animation: animation,
        onPop: () => setState(() {}),
      ),
    );

  void _switchRequiredItem(Item item) =>
    setState(() {
      if (!_filters.requiredItems.remove(item)) {
        _filters.requiredItems.add(item);
        _filters.excludedItems.remove(item);
      }
    });

  void _switchExcludedItem(Item item) =>
    setState(() {
      if (!_filters.excludedItems.remove(item)) {
        _filters.excludedItems.add(item);
        _filters.requiredItems.remove(item);
      }
    });

  @override
  void initState() {
    super.initState();
    sharedData.updateUserPosition();
  }

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
          title: Text('McDo ${sharedData.currentLocation?.name ?? ''}'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsetsGeometry.fromLTRB(16.0, 16.0, 16.0, 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 16.0,
              children: [
                Row(
                  spacing: 16.0,
                  children: [
                    ElevatedButton(
                      onPressed: () => _openLocationsPage(context),
                      child: const Padding(
                        padding: EdgeInsetsGeometry.all(10.0),
                        child: Icon(Icons.location_searching_rounded),
                      )
                    ),

                    Spacer(),

                    ElevatedButton(
                      onPressed: () => _openFiltersPage(context),
                      child: const Padding(
                        padding: EdgeInsetsGeometry.all(10.0),
                        child: Icon(Icons.filter_alt_rounded),
                      )
                    ),
                  ],
                ),

                FutureBuilder(
                  future: sharedData.currentLocation?.availableItems,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting
                      || snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Row(
                        children: [
                          Text('Calories : 0.0 kcal'),
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
                    future: sharedData.currentLocation?.availableItems,
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
                              .map((item) => Padding(
                                padding: const EdgeInsetsGeometry.all(4.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _filters.requiredItems.contains(item)
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Theme.of(context).hoverColor,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: InkWell(
                                    key: ValueKey(item.id),
                                    onTap: () => _switchRequiredItem(item),
                                    onLongPress: () => _switchExcludedItem(item),
                                    child: Padding(
                                      padding: const EdgeInsetsGeometry.fromLTRB(4.0, 0.0, 8.0, 0.0),
                                      child: Row(
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
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                          ],
                        );
                      }
                    },
                  ),
                ),

                Row(
                  spacing: 16.0,
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Target Calories',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onChanged: (input) => setState(() => _targetCalories = double.tryParse(input) ?? 0.0),
                        autofocus: false,
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () => setState(() {
                        ++_randomSeed;
                        _isRandom = true;
                      }),
                      onLongPress: () => setState(() => _isRandom = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRandom ? Color.fromARGB(255, 64, 54, 118) : null,
                        foregroundColor: _isRandom ? Colors.white : null,
                      ),
                      child: const Padding(
                        padding: EdgeInsetsGeometry.all(14.0),
                        child: Text('Randomize'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

