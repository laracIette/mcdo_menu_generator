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

  List<Location> _getLocations() {
    final Set<Location> locations = {
      Location(id: 335245, name: "McDo Zero"),
      Location(id: 546456, name: "McDo One"),
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
                elevation: 12,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx > 100.0) {
                      Navigator.pop(context);
                    }
                  },
                  child: Column(
                    children: [
                      AppBar(
                        automaticallyImplyLeading: false,
                        title: Text('Locations'),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
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
                                    children: [
                                      Column(
                                        children: [
                                          Text(location.name),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
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