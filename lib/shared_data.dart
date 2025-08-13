import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcdo_menu_generator/filters.dart';
import 'package:mcdo_menu_generator/location.dart';

class SharedData {
  Location? _currentLocation;

  Location? get currentLocation => _currentLocation;

  set currentLocation(Location? loc) {
    if (loc == _currentLocation) {
      return;
    }
    _currentLocation = loc;
    var box = Hive.box<Location>('app_data');
    if (loc != null) {
      box.put('currentLocation', loc);
    } else {
      box.delete('currentLocation');
    }
  }

  final Filters filters = Filters();
  late Future<Position?> userPositionFuture;

  void updateUserPosition() {
    userPositionFuture = _getUserPosition();
  }

  Future<Position?> _getUserPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Check for permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}

final sharedData = SharedData();