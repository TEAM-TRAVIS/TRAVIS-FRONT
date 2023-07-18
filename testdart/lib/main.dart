import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;
  LocationData? currentLocation;
  List<LatLng> routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    routeCoordinates = [];
    initLocation();
  }

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

    location.onLocationChanged.listen((LocationData result) {
      setState(() {
        currentLocation = result;
        routeCoordinates.add(LatLng(result.latitude!, result.longitude!));
      });

      if (mapController != null) {
        mapController.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(result.latitude!, result.longitude!),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('GPS 경로'),
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(37.7749, -122.4194), // 초기 지도 중심 좌표
                zoom: 14.0,
              ),
              polylines: <Polyline>{
                Polyline(
                  polylineId: PolylineId("route"),
                  color: Colors.red,
                  width: 5,
                  points: routeCoordinates,
                ),
              },
            ),
            Positioned(
              bottom: 50,
              left: 20,
              child: Text(
                '현재 위치: ${currentLocation?.latitude}, ${currentLocation?.longitude}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
