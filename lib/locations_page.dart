import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcdo_menu_generator/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mcdo_menu_generator/shared_data.dart';
import 'package:mcdo_menu_generator/utils.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key, required this.animation, required this.onPop});

  final Animation<double> animation;
  final void Function() onPop;

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  String _input = '';
  bool _showIds = false;

  late final Future<List<Location>> _allLocationsFuture = _getAllLocations();

  Future<List<Location>> _getLocations() async {
    final allLocations = await _allLocationsFuture;
    final userPosition = await sharedData.userPositionFuture;

    if (userPosition != null) {
      for (final location in allLocations) {
        location.distance = Geolocator.distanceBetween(
          userPosition.latitude, userPosition.longitude,
          location.latitude, location.longitude
        );
      }

      allLocations.sort((a, b) => a.distance!.compareTo(b.distance!));
    }
    return allLocations;
  }

  Future<List<Location>> _getAllLocations() async {
    final jsonString = await rootBundle.loadString('assets/data/restaurants_essentials.json');
    final json = jsonDecode(jsonString);
    final data = json as List;

    return data.map((restaurant) => Location(
      id: restaurant['ref'] as int? ?? 0,
      name: restaurant['name'] as String? ?? '',
      latitude: restaurant['latitude'] as double? ?? 0.0,
      longitude: restaurant['longitude'] as double? ?? 0.0,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.pop(context),
            child: Container(),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.85,
              heightFactor: 1.0,
              child: Material(
                elevation: 12.0,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.onPrimaryFixedVariant,
                        Theme.of(context).colorScheme.onSecondaryFixedVariant,
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.velocity.pixelsPerSecond.dx < -50.0) {
                        Navigator.pop(context);
                        widget.onPop();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsetsGeometry.fromLTRB(16.0, 16.0, 16.0, 32.0),
                      child: Column(
                        spacing: 16.0,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          Padding(
                            padding: EdgeInsetsGeometry.fromLTRB(4.0, 0.0, 4.0, 0.0),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.numbers_rounded, size: iconSize),
                                  onPressed: () => setState(() => _showIds = !_showIds),
                                ),

                                Spacer(),

                                IconButton(
                                  icon: const Icon(Icons.refresh, size: iconSize),
                                  onPressed: () => setState(() => sharedData.updateUserPosition()),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: FutureBuilder(
                              future: _getLocations(),
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
                                  final locations = snapshot.data!;
                                  //_locations.sort((a, b) => a.distance.compareTo(b.distance));
                                  return ListView(
                                    padding: EdgeInsets.zero, // todo: necessary for top padding but why?
                                    children: [
                                      ...locations
                                        .where((location) => _input.isEmpty
                                          || location.id == int.tryParse(_input)
                                          || location.name.toLowerCase().contains(_input.toLowerCase())
                                        )
                                        .map((location) => Padding(
                                          padding: const EdgeInsetsGeometry.all(2.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: sharedData.currentLocation == location
                                                ? Theme.of(context).highlightColor
                                                : Colors.transparent,
                                              borderRadius: BorderRadius.circular(6.0),
                                            ),
                                            child: InkWell(
                                              key: ValueKey(location.id),
                                              onTap: () {
                                                sharedData.currentLocation = location;
                                                Navigator.pop(context);
                                                widget.onPop();
                                              },
                                              borderRadius: BorderRadius.circular(6.0),
                                              child: Padding(
                                                padding: const EdgeInsetsGeometry.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: location.name,
                                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                            if (location.distance != null)
                                                              TextSpan(
                                                                text: location.distance! < 1000.0
                                                                  ? '  ${(location.distance!).toInt()}m'
                                                                  : '  ${(location.distance! / 1000.0).toStringAsFixed(2)}km',
                                                                style: const TextStyle(color: Color.fromARGB(255, 202, 202, 202)),
                                                              ),
                                                            if (_showIds)
                                                              TextSpan(
                                                                text: '  ${location.id.toString()}',
                                                                style: const TextStyle(color: Colors.grey),
                                                              ),
                                                          ],
                                                        ),
                                                        softWrap: true,
                                                        overflow: TextOverflow.visible,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                                    ],
                                  );
                                }
                              }
                            ),
                          ),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Search Location',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            onChanged: (input) => setState(() => _input = input),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}