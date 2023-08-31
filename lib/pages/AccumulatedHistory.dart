import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:Travis/Provider.dart';
import 'package:Travis/pages/Map.dart';
import 'package:Travis/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:xml/xml.dart';

class AccumulatedHistory extends StatefulWidget {
  final List<String> selectedList;
  const AccumulatedHistory({super.key, required this.selectedList});

  @override
  State<AccumulatedHistory> createState() => _AccumulatedHistoryState();
}

class _AccumulatedHistoryState extends State<AccumulatedHistory> with ChangeNotifier {
  late GoogleMapController mapController;
  late String? gpxData;
  List<LatLng> route = [];
  List<dynamic> routes = [];
  final String getGPSUrl = "http://44.218.14.132/gps/detail";
  final String getOneSummaryUrl = "http://44.218.14.132/gps/summary";
  String title = "";
  String content = "";
  Utils utils = Utils();
  final Set<Polyline> _polylines = {};
  late PolylineId _selectedPolylineId;

  @override
  void initState() {
    super.initState();
    route = [];
    routes = [];
    for (String date in widget.selectedList) {
      getGPS(context, date)
          // .then((value) => print("initState에서의 route 길이 : ${parseGpx(value).length}"));
          .then((gpxData) => routes.add(parseGpx(gpxData)));
    }
    // print("routes : $routes");
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
  }

  Future getGPS(BuildContext context, String date) async {
    try {
      var response = await http.post(
        Uri.parse(getGPSUrl),
        headers: <String, String>{
          'Content-Type': 'application/json;charSet=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': Provider.of<UserProvider>(context, listen: false).userEmail!,
          'date': date,
        }),
      ); //post

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 201) {
        GZipCodec gzip = GZipCodec();
        try {
          var data = jsonDecode(response.body);
          var encodedString = data['gzipFile'];
          List<int> zippedRoute = base64.decode(encodedString);
          List<int> decodedzip = gzip.decode(zippedRoute);
          gpxData = utf8.decode(decodedzip);
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      debugPrint('오류 발생: $e');
    }
    return gpxData;
  }

  Future getOneSummary(BuildContext context) async {
    try {
      var response = await http.post(Uri.parse(getOneSummaryUrl),
        headers: <String, String>{
          'Content-Type': 'application/json;charSet=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': Provider.of<UserProvider>(context, listen: false).userEmail!,
          'date': Provider.of<HistoryProvider>(context, listen: false).date!.replaceFirst('Z', '+00:00'),
        }),
      ); //post
      print("History Status Code: ${response.statusCode}");
      print(response.body);
      if (response.statusCode == 200) {
        try {
          var data = jsonDecode(response.body);
          setState(() {
            title = data['oneSummary']['title'];
            content = data['oneSummary']['content'];
          });
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      debugPrint('오류 발생: $e');
    }
  }

  // void parseGpx(gpxData) {
  List<dynamic> parseGpx(gpxData) {
    route = [];
    try {
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
      print(e);
    }
    return route;
  }

  void _drawPolylines() {
    for (int i = 0; i < routes.length; i++) {
      PolylineId polylineId = PolylineId('route_$i'); // 고유한 ID 생성
      Polyline polyline = Polyline(
        polylineId: polylineId,
        color: _selectedPolylineId == polylineId
            ? Colors.blue
            : Colors.grey,
        width: 5,
        points: routes[i],
        onTap: () {
          setState(() {
            _selectedPolylineId = polylineId; // Polyline 선택
          });
        },
      );
      _polylines.add(polyline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Scaffold(
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
                Navigator.pop(context);
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

                },
                child: Text(
                  "test",
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
                  // _drawPolylines();
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(((latmax - latmin) / 2 + latmin),
                      ((lonmax - lonmin) / 2 + lonmin)), // 초기 지도 중심 좌표
                  zoom:
                  -log(max((latmax - latmin), (lonmax - lonmin)) / 256) / ln2,
                ),
                polylines: <Polyline> {
                  for (int i = 0; i < routes.length; i++)
                    for (int j = 0; j < routes[i].length - 1; j++)
                      Polyline(
                        polylineId: PolylineId("route_$i"),
                        color: Colors.blue,
                        width: 5,
                        points: [
                          routes[i].first, // 시작점
                          ...routes[i],    // 경로의 좌표들
                          routes[i].last,
                        ],
                        // points: [routes[i][j], routes[i][j+1]],
                      ),
                  // for (int j = 0; j < route.length - 1; j++)
                  //   Polyline(
                  //     polylineId: PolylineId(""),
                  //     color: Colors.blue,
                  //     width: 5,
                  //     // points: [route[j], route[j+1]],
                  //     points: [
                  //       route.first, // 시작점
                  //       ...route,    // 경로의 좌표들
                  //       route.last,
                  //     ],
                  //   ),
                },
                zoomControlsEnabled: false,
              ),
              SlidingUpPanel(
                minHeight: MediaQuery.of(context).size.height * 0.1,
                maxHeight: MediaQuery.of(context).size.height * 0.3,
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
                                    "hi",
                                    // utils.formatTime(Provider.of<HistoryProvider>(context, listen: false).time),
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
                                    "hi",
                                    // "${Provider.of<HistoryProvider>(context, listen: false).dist}km",
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
