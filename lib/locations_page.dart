import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcdo_menu_generator/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mcdo_menu_generator/shared_data.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key, required this.animation, required this.onPop});

  final Animation<double> animation;
  final void Function() onPop;

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  late final Future<List<Location>> _allLocationsFuture = _getAllLocations();

  String _input = '';

  bool _showIds = false;

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
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx < -50.0) {
                      Navigator.pop(context);
                      widget.onPop();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                    child: Column(
                      spacing: 16.0,
                      children: [
                        AppBar(
                          automaticallyImplyLeading: false,
                          title: const Text('Locations'),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onPop();
                              },
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => setState(() => _showIds = !_showIds),
                              child: Text(_showIds ? 'Hide IDs' : 'Show IDs'),
                            ),

                            Spacer(),

                            ElevatedButton(
                              onPressed: () => setState(() => sharedData.updateUserPosition()),
                              child: const Text('Update Position'),
                            ),
                          ],
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
                                        padding: const EdgeInsets.all(2.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: sharedData.currentLocation == location
                                              ? Theme.of(context).highlightColor
                                              : Colors.transparent,
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: InkWell(
                                            key: ValueKey(location.id),
                                            onTap: () {
                                              sharedData.currentLocation = location;
                                              Navigator.pop(context);
                                              widget.onPop();
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
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
                          decoration: const InputDecoration(
                            labelText: 'Search Location',
                            border: OutlineInputBorder(),
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
        ],
      ),
    );
  }
}