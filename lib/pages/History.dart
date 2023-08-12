import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:Travis/User.dart';
import 'package:Travis/pages/Map.dart';
import 'package:Travis/pages/MyPage.dart';
import 'package:Travis/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:xml/xml.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> with ChangeNotifier {
  late GoogleMapController mapController;
  late String? gpxData;
  List<LatLng> route = [];

  @override
  void initState() {
    save(context);
    super.initState();
    route = [];
  }

  final String url = "http://44.218.14.132/gps/detail";

  Future save(BuildContext contexts) async {
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json;charSet=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': Provider.of<UserProvider>(context, listen: false).userEmail!,
          'date': Provider.of<DateProvider>(context, listen: false).date!,
        }),
      ); //post

      print(response.statusCode);
      // print(response.body);

      if (response.statusCode == 201) {
        GZipCodec gzip = GZipCodec();
        print("History 페이지에 들어왔습니다.");
        try {
          print("제대로 들어왔습니다.");
          var data = jsonDecode(response.body);
          var encodedString = data['gzipFile'];
          List<int> zippedRoute = base64.decode(encodedString);
          List<int> decodedzip = gzip.decode(zippedRoute);
          gpxData = utf8.decode(decodedzip);
          print("History 페이지의 gpxData: $gpxData");
          parseGpx(gpxData);
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      debugPrint('오류 발생: $e');
    }
  }

  void parseGpx(gpxData) {
    try {
      print("parseGpx 하겠습니다.");
      final document = XmlDocument.parse(gpxData);
      final wptElements = document.findAllElements('wpt');

      XmlNode metadataElement = document.findAllElements('metadata').first;
      XmlNode boundsElement = metadataElement.findElements('bounds').first;

      final minLatAttr = boundsElement.getAttribute('minlat');
      final minLonAttr = boundsElement.getAttribute('minlon');
      final maxLatAttr = boundsElement.getAttribute('maxlat');
      final maxLonAttr = boundsElement.getAttribute('maxlon');

      latmin = double.tryParse(minLatAttr!)!;
      lonmin = double.tryParse(minLonAttr!)!;
      latmax = double.tryParse(maxLatAttr!)!;
      lonmax = double.tryParse(maxLonAttr!)!;

      setState(() {
        for (final wptElement in wptElements) {
          final latAttr = wptElement.getAttribute('lat');
          final lonAttr = wptElement.getAttribute('lon');

          if (latAttr != null && lonAttr != null) {
            final lat = double.tryParse(latAttr);
            final lon = double.tryParse(lonAttr);
            if (lat != null && lon != null) {
              LatLng latlng = LatLng(lat, lon);
              route.add(latlng);
            }
          }
        }
      });
    } catch (e) {
      print("파싱이 안된것같습니다.");
    }
  }

  String formatTime(seconds) {
    Duration duration = Duration(seconds: seconds);
    return DateFormat('HH:mm:ss').format(DateTime(0).add(duration));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "History",
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MyPage()));
            },
            child: Text(
              "Back",
              style: SafeGoogleFont(
                'NanumGothic',
                fontSize: 15,
                color: Colors.red,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("share button clicked");
                // print(gpxData);
                // print(route[0]);
                // print(gpxData);
                print(latmin);
                print(latmax);
                print(lonmin);
                print(lonmax);
                print(route);
              },
              child: Text(
                "Share",
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
                for (int i = 0; i < route.length - 1; i++)
                  Polyline(
                    polylineId: PolylineId("route_$i"),
                    color: Colors.blue,
                    width: 5,
                    points: [route[i], route[i + 1]],
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
                BoxShadow(blurRadius: 0),
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
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "hihi",
                                    // time,
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
                                      color: const Color.fromARGB(
                                          255, 163, 163, 163),
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
                                    "hello",
                                    // '${(totalDistance/1000).toStringAsFixed(1)}km',
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
                                      color: const Color.fromARGB(
                                          255, 163, 163, 163),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
