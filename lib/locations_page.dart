import 'package:flutter/material.dart';
import 'package:mcdo_menu_generator/location.dart';

typedef LocationUpdatedFunction = Function(Location);

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key, required this.animation, required this.onLocationUpdated, required this.currentLocation});

  final Animation<double> animation;
  final LocationUpdatedFunction onLocationUpdated;
  final Location currentLocation;

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  LocationUpdatedFunction get _onLocationUpdated => widget.onLocationUpdated;
  Location get _currentLocation => widget.currentLocation;

  bool _showIds = false;

  List<Location> _getLocations() {
    final Set<Location> locations = {
      Location(id: 1717, name: "MOI"),
      Location(id: 208, name: "Compans-Cafarelli"),
    };
    return locations.toList()..sort((a, b) => a.getDistance().compareTo(b.getDistance()));
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
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                ),
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx < -50.0) {
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      spacing: 16.0,
                      children: [
                        AppBar(
                          automaticallyImplyLeading: false,
                          title: const Text('Locations'),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),

                        Row(
                          spacing: 16.0,
                          children: [
                            const Text('Show IDs'),
                            ElevatedButton(
                              onPressed: () => setState(() => _showIds = !_showIds),
                              child: Text(_showIds.toString()),
                            ),
                          ],
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ..._getLocations().map((location) => InkWell(
                                  key: ValueKey(location),
                                  onTap: () {
                                    _onLocationUpdated(location);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    color: _currentLocation == location
                                      ? Colors.blue.withValues(alpha: 0.2)
                                      : Colors.transparent,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      spacing: 16.0,
                                      children: [
                                        Text(location.name),
                                        if (_showIds) Text(
                                          location.id.toString(),
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                              ],
                            )
                          ),
                        ),
                      ]
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