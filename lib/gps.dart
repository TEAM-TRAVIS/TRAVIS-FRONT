import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';

class GPS {
  late GoogleMapController mapController;
  late Timer timer;
  int milliseconds = 0;
  double totalDistance = 0.0;
  bool isTracking = false;
  LocationData? currentLocation;
  List<LatLng> routeCoordinates = [];

  GPS() {
    routeCoordinates = [];
    initLocation();
  }

  // 위치 권한이 있는지 확인하고 없으면 위치 권한을 받는 함수
  void initLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.throttle((_) => TimerStream(true, const Duration(seconds: 3)))
        .listen((LocationData locationData) {
      currentLocation = locationData;
      if (isTracking) {
        LatLng currentLatLng = LatLng(locationData.latitude!, locationData.longitude!);
        if (routeCoordinates.isNotEmpty) {
          totalDistance += calculateDistance(routeCoordinates.last, currentLatLng);
        }
        routeCoordinates.add(currentLatLng);
      }
      mapController.animateCamera(
        CameraUpdate.newLatLng(LatLng(locationData.latitude! - 0.001, locationData.longitude!)),
      );
    });
  }

  double calculateDistance(LatLng latLng1, LatLng latLng2) {
    double distanceInMeters = Geolocator.distanceBetween(
      latLng1.latitude,
      latLng1.longitude,
      latLng2.latitude,
      latLng2.longitude,
    );
    return distanceInMeters;
  }

  double calculateTotalDistance() {
    double totalDistance = 0.0;
    for (int i = 0; i < routeCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(routeCoordinates[i], routeCoordinates[i + 1]);
    }
    return totalDistance;
  }

  String formatTime() {
    Duration duration = Duration(milliseconds: milliseconds);
    return DateFormat('HH:mm:ss').format(DateTime(0).add(duration));
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 10), (Timer timer) {
      milliseconds += 10;
    });
  }

  void stopTimer() {
    timer.cancel();
    milliseconds = 0;
  }

  void toggleTimer() {
    if (isTracking) {
      stopTimer();
    } else {
      startTimer();
    }
    isTracking = !isTracking;
  }

  void startTracking() {
    routeCoordinates.clear();
    isTracking = true;
    totalDistance = 0.0;
  }

  void stopTracking() {
    isTracking = false;
    totalDistance = calculateTotalDistance();
  }
}