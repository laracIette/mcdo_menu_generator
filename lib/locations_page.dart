import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  late final Future<List<Location>> _locationsFuture = _getLocations();
  List<Location> _locations = [];

  bool _showIds = false;

  String _input = '';

  Future<List<Location>> _getLocations() async {
    final url = Uri.parse('https://www.mcdonalds.fr/liste-restaurants-mcdonalds-france');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final html = response.body;

      // Regex: captures name and id
      final regex = RegExp(
        r'https://www\.mcdonalds\.fr/restaurants/([a-z0-9\-]+)/(\d+)',
        caseSensitive: false,
      );

      final locations = regex.allMatches(html)
        .map((match) => Location(
          id: int.tryParse(match.group(2) ?? '') ?? 0,
          name: match.group(1)?.substring(10).replaceAll('-', ' ')
            .split(' ')
            .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
            .join(' ')
            ?? 'Error',
          url: 'https://www.mcdonalds.fr/restaurants/${match.group(1)}/${match.group(2)}',
        )).toSet();

      return locations.toList();
    }

    return [];
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
                            Expanded(
                              child: TextField(
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: false,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Location',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (input) => setState(() => _input = input),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => setState(() => _showIds = !_showIds),
                              child: Text(_showIds ? 'Hide IDs' : 'Show IDs')
                            ),
                          ],
                        ),

                        FutureBuilder(
                          future: _locationsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }
                            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(child: Text('No items found'));
                            }
                            else {
                              _locations = snapshot.data!;
                              //_locations.sort((a, b) => a.getDistance().compareTo(b.getDistance()));
                              return Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      ..._locations.where((location) => _input.isEmpty || location.id == int.tryParse(_input) || location.name.toLowerCase().contains(_input.toLowerCase()))
                                        .map((location) => InkWell(
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
                              );
                            }
                          }
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