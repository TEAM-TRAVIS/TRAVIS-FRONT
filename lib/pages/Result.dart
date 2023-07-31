import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:Travis/pages/Map.dart';
import 'package:Travis/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:gpx/gpx.dart';
import 'package:Travis/pages/MyPage.dart';

class Result extends StatefulWidget {
  const Result({super.key});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  late GoogleMapController mapController;

  final String url = "http://172.17.96.1:3000/gps/save";
  Future save(Gpx gpxData) async {
    final gpxString = GpxWriter().asString(gpxData, pretty: true);
    print(gpxString);
    final gpxGzip = GZipCodec().encode(utf8.encode(gpxString));
    final gpxBase64 = base64.encode(gpxGzip);
    String test = "hello";
    try {
      var response = await http.post(Uri.parse(url),
          headers: <String, String>{
            // 'Content-Type': 'application/gzip',
            'Content-Type': 'application/json;charSet=UTF-8',
          },
          body: jsonEncode(<String, String>{
            // 'body': test,
            'body' : gpxBase64,
          }),
      ); //post
      print(response.statusCode);
      print(response.body);
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  // void printZoomLevel() async {
  //   double zoomLevel = await mapController.getZoomLevel();
  //   print('Current Zoom Level: $zoomLevel');
  // }

  @override
  Map map = const Map();
  Widget build(BuildContext context) {
    final Gpx gpxData = ModalRoute.of(context)!.settings.arguments as Gpx;
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
                save(gpxData);
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const MyPage()));
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
              //
              initialCameraPosition: CameraPosition(
                target: LatLng(((latmax - latmin) /2 + latmin), ((lonmax - lonmin) /2 + lonmin)), // 초기 지도 중심 좌표
                zoom: -log( max((latmax - latmin), (lonmax - lonmin)) / 256) / ln2,
              ),
              polylines: <Polyline>{
                Polyline(
                    polylineId: const PolylineId("route"),
                    color: Colors.blue,
                    width: 8,
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
                    // Expanded(
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Expanded(
                    //         child: Center(
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               Text(
                    //                 toogleTimer();
                    //                 style: SafeGoogleFont(
                    //                   'MuseoModerno',
                    //                   fontSize: 25,
                    //                   fontWeight: FontWeight.w500,
                    //                 ),
                    //               ),
                    //               const Divider(
                    //                 color: Color.fromARGB(255, 217, 217, 217),
                    //                 height: 1,
                    //                 thickness: 1,
                    //               ),
                    //               Text("Time",
                    //                 style: SafeGoogleFont(
                    //                   'NanumGothic',
                    //                   fontSize: 10,
                    //                   fontWeight: FontWeight.normal,
                    //                   color: const Color.fromARGB(255, 163, 163, 163),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(
                    //         width: 30,
                    //       ),
                    //       Expanded(
                    //         child: Center(
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               isTracking ?
                    //               Text('${(totalDistance/1000).toStringAsFixed(1)}km',
                    //                   style: SafeGoogleFont(
                    //                       'MuseoModerno',
                    //                       fontSize: 25,
                    //                       fontWeight: FontWeight.w500)) :
                    //               Text('0km',
                    //                   style: SafeGoogleFont(
                    //                       'MuseoModerno',
                    //                       fontSize: 25,
                    //                       fontWeight: FontWeight.w500)),
                    //               const Divider(
                    //                 color: Color.fromARGB(255, 217, 217, 217),
                    //                 height: 1,
                    //                 thickness: 1,
                    //               ),
                    //               Text("Distance",
                    //                 style: SafeGoogleFont(
                    //                   'NanumGothic',
                    //                   fontSize: 10,
                    //                   fontWeight: FontWeight.normal,
                    //                   color: const Color.fromARGB(255, 163, 163, 163),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
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