import 'package:flutter/material.dart';
import 'package:Travis/pages/Result.dart';
import 'package:Travis/utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:Travis/gps.dart';

List<LatLng> routeCoordinates = []; // LatLng 객체들을 담는 리스트. 지도상의 경로나 마커 위치 등을 저장하는데 사용.

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  _MapState createState() => _MapState();
}

// 이 클래스는 지도를 표시하고, 사용자의 현재 위치를 얻어서 currentLocation 변수에 저장하며, 지도 상의 경로를 routeCoordinates 리스트에 저장하는 기능을 수행.
class _MapState extends State<Map> {
  final GPS gps = GPS();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Record",
            style: SafeGoogleFont(
              'MuseoModerno',
              fontSize: 21,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: TextButton(
            onPressed: () {
              print("back button clicked");
            },
            child: Text("back",
              style: SafeGoogleFont(
                'NanumGothic',
                fontSize: 18,
              ),
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  print("settings button clicked");
                },
                icon: Icon(Icons.settings,
                  color: Colors.blue[500],
                ),
            ),
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                gps.mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // 초기 지도 중심 좌표
                zoom: 12.0,
              ),
              polylines: <Polyline>{
                if (gps.isTracking)
                  Polyline(
                    polylineId: PolylineId("route"),
                    color: Colors.blue,
                    width: 5,
                    points: gps.routeCoordinates
                  ),
              },
              zoomControlsEnabled: false,
              markers: <Marker>{
                Marker(
                  markerId: MarkerId('currentLocation'),
                  position: LatLng(gps.currentLocation!.latitude!, gps.currentLocation!.longitude!),
                  infoWindow: InfoWindow(title: 'My Location'),
                ),
              },
            ),
            SlidingUpPanel(
              minHeight: 70,
              maxHeight: 225,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: const [
                BoxShadow(
                    blurRadius: 0
                ),
              ],
              header: Padding(
                padding: const EdgeInsets.only(left: 150, right: 150, top: 5),
                child: Container(
                  alignment: Alignment.center,
                  width: 100,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 217, 217, 217), // 회색 배경 색상
                    borderRadius: BorderRadius.circular(10), // 모서리 둥글기 설정
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              panel: Container(
                margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 235),
                      child: Text("Travel path",
                        style: SafeGoogleFont(
                          'MuseoModerno',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 217, 217, 217),
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        gps.toggleTimer();
                        gps.isTracking ? gps.stopTracking : gps.startTracking;
                      },
                      style: gps.isTracking?
                        ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 3, 43, 166)),
                          minimumSize: MaterialStateProperty.all(const Size(double.infinity, 38)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))) :
                        ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 41, 91, 241)),
                            minimumSize: MaterialStateProperty.all(const Size(double.infinity, 38)),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                      child: Text(gps.isTracking ? 'Stop' : 'Start',
                        style: SafeGoogleFont(
                          'NanumGothic',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      child: Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      gps.formatTime(),
                                      style: SafeGoogleFont(
                                        'MuseoModerno',
                                        fontSize: 25,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Divider(
                                      color: Color.fromARGB(255, 217, 217, 217),
                                      height: 1,
                                      thickness: 1,
                                    ),
                                    Text("Time",
                                      style: SafeGoogleFont(
                                        'NanumGothic',
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal,
                                        color: Color.fromARGB(255, 163, 163, 163),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    gps.isTracking ?
                                      Text('${(gps.totalDistance/1000).toStringAsFixed(1)}km',
                                        style: SafeGoogleFont(
                                          'MuseoModerno',
                                          fontSize: 25,
                                          fontWeight: FontWeight.w500)) :
                                      Text('0km',
                                        style: SafeGoogleFont(
                                          'MuseoModerno',
                                          fontSize: 25,
                                          fontWeight: FontWeight.w500)),
                                    const Divider(
                                      color: Color.fromARGB(255, 217, 217, 217),
                                      height: 1,
                                      thickness: 1,
                                    ),
                                    Text("Distance",
                                      style: SafeGoogleFont(
                                        'NanumGothic',
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal,
                                        color: Color.fromARGB(255, 163, 163, 163),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
