import 'dart:math';

import 'package:flutter/material.dart';
import 'package:Travis/pages/Map.dart';
import 'package:Travis/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:location/location.dart';

class Result extends StatefulWidget {
  const Result({super.key});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  late GoogleMapController mapController;

  void printZoomLevel() async {
    double zoomLevel = await mapController.getZoomLevel();
    print('Current Zoom Level: $zoomLevel');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Result",
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
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const Map()));
            },
            child: Text("Cancel",
              style: SafeGoogleFont(
                'NanumGothic',
                fontSize: 13,
                color: Colors.red,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print(latmax);
                print(latmin);
                print(lonmax);
                print(lonmin);
                printZoomLevel();
                print("위도차 ${latmax - latmin}");
                print("경도차 ${lonmax - lonmin}");
                print(((latmax - latmin) /2 + latmin));
                print(((lonmax - lonmin) /2 + lonmin));
                print("save button clicked");
              },
              child: Text("Save",
                style: SafeGoogleFont(
                  'NanumGothic',
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(((latmax - latmin) /2 + latmin), ((lonmax - lonmin) /2 + lonmin)), // 초기 지도 중심 좌표
                zoom: 9.2166 * exp(-3.3976 * max((latmax - latmin), (lonmax - lonmin))) + 5.5,
              ),
              polylines: <Polyline>{
                Polyline(
                    polylineId: const PolylineId("route"),
                    color: Colors.blue,
                    width: 5,
                    points: routeCoordinates
                ),
              },
              zoomControlsEnabled: false,
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
                    // Container(
                    //   child:
                    // ),
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