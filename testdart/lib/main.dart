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
  void initState() { //routeCoordinates를 불러오고 location을 받아오기 위한 함수
    super.initState();
    routeCoordinates = [];
    initLocation();
  }

  void initLocation() async { // initstate에 의해서만 호출됨
    Location location = Location();  //Location은 gps 위치를 받아오는 '클래스' location은 객체 즉 객체 생성

    bool serviceEnabled; //서비스가 가능한지 위치를 받아왔는지 확인하는 flag?
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
