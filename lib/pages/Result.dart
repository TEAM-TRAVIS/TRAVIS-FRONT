import 'dart:convert';
import 'dart:io';
import 'package:Travis/pages/Map.dart';
import 'package:Travis/pages/MyPage.dart';
import 'package:flutter/material.dart';
import 'package:Travis/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:gpx/gpx.dart';
import 'package:Travis/Arguments.dart';
import 'package:xml/xml.dart';

class Result extends StatefulWidget {
  const Result({super.key});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  late GoogleMapController mapController;
  final String saveGPSUrl = "http://44.218.14.132/gps/save";
  String? titleValue = "";
  String? contentValue = "";

  Future saveGPS(Gpx gpxData) async {
    final gpxString = GpxWriter().asString(gpxData, pretty: true);
    debugPrint("GpxString 출력결과: $gpxString");
    debugPrint("-------------");
    final gpxGzip = GZipCodec().encode(utf8.encode(gpxString));
    final gpxBase64 = base64.encode(gpxGzip);

    /// gpxString을 xml 형식으로 parse
    XmlDocument document = XmlDocument.parse(gpxString);
    /// document에서 user의 email 분리
    XmlNode emailnode = document.findAllElements('name').first;
    String emailValue = emailnode.innerText;
    /// document에서 현재 경로의 distance 분리
    XmlNode distnode = document.findAllElements('keywords').first;
    String distValue = distnode.innerText;
    /// document에서 현재 경로의 time 분리
    XmlNode timenode = document.findAllElements('desc').first;
    String timeValue = timenode.innerText;

    try {
      var response = await http.post(Uri.parse(saveGPSUrl),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'email': emailValue,
            'dist' : distValue,
            'time' : timeValue,
            'title' : titleValue!,
            'content' : contentValue!,
            'file' : gpxBase64,
          }),
      ); //post
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 201) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => MyPage()));
    } else {
        Fluttertoast.showToast(
          msg: "Temporary network error occured!",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 3,
        );
      }
    } catch (e) {
      debugPrint('오류 발생: $e');
    }
  }

  // void debugPrintZoomLevel() async {
  //   double zoomLevel = await mapController.getZoomLevel();
  //   debugPrint('Current Zoom Level: $zoomLevel');
  // }

  @override
  Widget build(BuildContext context) {
    final ResultArguments args = ModalRoute.of(context)!.settings.arguments as ResultArguments;
    final Gpx gpxData = args.gpx;
    final int milliseconds = args.milliseconds;
    final totalDistance = args.totalDistance;
    Duration duration = Duration(milliseconds: milliseconds);
    String time = DateFormat('HH:mm:ss').format(DateTime(0).add(duration));
    double panelHeightOpen = MediaQuery.of(context).size.height * 0.5;
    double panelHeightClose = MediaQuery.of(context).size.height * 0.1;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Result",
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
            child: Text(
              "Cancel",
              style: SafeGoogleFont(
                'NanumGothic',
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                saveGPS(gpxData);
              },
              child: Text(
                "Save",
                style: SafeGoogleFont(
                  'NanumGothic',
                  fontSize: 15,
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
                target: LatLng(((latmax - latmin) / 2 + latmin),
                    ((lonmax - lonmin) / 2 + lonmin)), // 초기 지도 중심 좌표
                zoom:
                    -log(max((latmax - latmin), (lonmax - lonmin)) / 256) / ln2,
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
              minHeight: panelHeightClose,
              maxHeight: panelHeightOpen,
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Travel path",
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
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  time,
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
                                Text(
                                  "Time",
                                  style: SafeGoogleFont(
                                    'NanumGothic',
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                    color: const Color.fromARGB(255, 163, 163, 163),
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
                                Text(
                                  "${(totalDistance/1000).toStringAsFixed(1)}km",
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
                                Text(
                                  "Distance",
                                  style: SafeGoogleFont(
                                    'NanumGothic',
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                    color: const Color.fromARGB(255, 163, 163, 163),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20, left: 1, right: 1),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromARGB(255, 217, 217, 217),
                              width: 1,
                            ),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              // controller: _emailController,
                              // focusNode: _emailFocusNode,
                              onChanged: (value) {
                                titleValue = value;
                              },
                              decoration: InputDecoration(
                                labelStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                hintText: 'Enter title of your journey',
                                contentPadding: EdgeInsets.only(left: 5),
                              ),
                            ),
                            TextField(
                              // controller: _emailController,
                              // focusNode: _emailFocusNode,
                              onChanged: (value) {
                                contentValue = value;
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                hintText: 'Enter brief description',
                                contentPadding: EdgeInsets.only(left: 5, top: 50, bottom: 0),
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