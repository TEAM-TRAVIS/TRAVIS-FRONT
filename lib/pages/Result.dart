import 'dart:convert';
import 'dart:io';
import 'package:Travis/pages/Map.dart';
import 'package:Travis/pages/MyPage.dart';
import 'package:flutter/material.dart';
import 'package:Travis/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:screenshot/screenshot.dart';
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
  final GlobalKey<ScreenshotState> screenshotKey = GlobalKey();
  late GoogleMapController mapController;
  final screenshotController = ScreenshotController();
  final String saveGPSUrl = "http://44.218.14.132/gps/save";
  String? titleValue = "";
  String? contentValue = "";
  bool isPublic = false;
  Utils utils = Utils();

  Future saveGPS(Gpx gpxData, BuildContext context, var image) async {
    final gpxString = GpxWriter().asString(gpxData, pretty: true);
    final gpxGzip = GZipCodec().encode(utf8.encode(gpxString));
    final gpxBase64 = base64.encode(gpxGzip);
    final imageBase64 = base64.encode(image);

    /// gpxString을 xml 형식으로 parse
    XmlDocument document = XmlDocument.parse(gpxString);
    /// document에서 user의 email 분리
    XmlNode emailnode = document.findAllElements('name').first;
    String emailValue = emailnode.innerText;
    /// document에서 현재 경로의 distance 분리
    XmlNode distnode = document.findAllElements('keywords').first;
    String distValue = distnode.innerText;
    print(distValue);
    /// document에서 현재 경로의 time 분리
    XmlNode timenode = document.findAllElements('desc').first;
    String timeValue = timenode.innerText;
    String city1 = await findRegion(routeCoordinates);

    try {
      var response = await http.post(Uri.parse(saveGPSUrl),
          headers: <String, String>{
            'Content-Type': 'application/json'
          },
          body: jsonEncode(<String, String>{
            'email': emailValue,
            'dist' : distValue,
            'time' : timeValue,
            'title' : titleValue!,
            'content' : contentValue!,
            'isPublic' : isPublic ? "true":"false",
            'GPSgzip' : gpxBase64,
            'city1' : city1,
            // 'file' : imageBase64,
          }),
      ); //post
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyPage()
          )
        );
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

  Future saveImage(BuildContext context, var image) async {
    var formData = http.MultipartRequest('POST', Uri.parse("http://44.218.14.132/img/save"));
    formData.files.add(http.MultipartFile.fromBytes(
      'file',
      image,
      filename: 'image.png',
    ));
    var response = await formData.send();
    print(response.statusCode);
    print(response);
  }

  Future<String> findRegion(routeCoordinates) async {
    String locality = "";
    List<String> region = [];
    String result = "";
    for (int i = 0; i < routeCoordinates.length; i += 600) {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(routeCoordinates[i].latitude!, routeCoordinates[i].longitude!);
      locality = placemarks.first.locality ?? "Unknown location";
      print(locality);
      region.add(locality);
    }
    region = region.where((city) => city.length >= 5).toList();
    result = region.join(", ");
    return result;
  }

  @override
  Widget build(BuildContext context) {
    ResultArguments args = ModalRoute.of(context)!.settings.arguments as ResultArguments;
    Gpx gpxData = args.gpx;
    int milliseconds = args.milliseconds;
    double distance = args.distance;
    double panelHeightOpen = MediaQuery.of(context).size.height * 0.5;
    double panelHeightClose = MediaQuery.of(context).size.height * 0.1;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Map(),
            ),
          );
          return false;
        },
        child: Screenshot(
          controller: screenshotController,
          child: Scaffold(
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Map(),
                    ),
                  );
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
                  onPressed: () async {
                    final image = await screenshotController.capture();
                    print(image.runtimeType);
                    final test = base64.encode(image!);
                    print(test.length);
                    print(test.runtimeType);
                    // saveGPS(gpxData, context, image);
                    // String city1 = await findRegion(routeCoordinates);
                    // print(city1);
                    // print(city1.runtimeType);
                  },
                  child: Text(
                    "test"
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final image = await screenshotController.capture();
                    saveGPS(gpxData, context, image);

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
                googleMap(),
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
                          height: 10,
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
                                      utils.formatTime(milliseconds),
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
                                      "${(distance/1000).toStringAsFixed(1)}km",
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
                          height: 10,
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 217, 217, 217),
                                  width: 1,
                                ),
                            ),
                            child: Column(
                              children: [
                                TextField(
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
                                    contentPadding: EdgeInsets.only(left: 5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 110,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    isPublic ? "Public" : "Private",
                                    style: SafeGoogleFont(
                                      'NanumGothic',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isPublic ? Colors.blue : Colors.red,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Switch(
                                    value: isPublic,
                                    onChanged: (value) {
                                      setState(() {
                                        isPublic = value;
                                      });
                                    }
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
      ),
    );
  }

  Widget googleMap() {
    return GoogleMap(
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
    );
  }
}