import 'dart:convert';
import 'dart:io';
import 'package:Travis/User.dart';
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

// class GpxData {
//   final List<LatLng> route;
//
//   GpxData(this.route);
// }

class _HistoryState extends State<History> with ChangeNotifier {
  late GoogleMapController mapController;
  String gpxData = "";
  List<LatLng> route = [];

  @override
  void initState() {
    save(context);
    super.initState();
    route = [];
  }

  final String url = "http://172.17.96.1:3000/gps/detail";
  Future save(BuildContext contexts) async {
    try {
      var response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json;charSet=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': Provider.of<UserProvider>(context, listen: false).userEmail!,
          'date': ModalRoute.of(context)!.settings.arguments as String,
        }),
      ); //post

      print(ModalRoute.of(context)!.settings.arguments);
      print(response.statusCode);
      // print(response.body);

      if (response.statusCode == 201) {
        GZipCodec gzip = GZipCodec();
        print("History 페이지에 들어왔습니다.");
        try {
          print("네 반갑습니다");
          var data = jsonDecode(response.body);
          var encodedString = data['gzipFile'];
          List<int> zippedRoute = base64.decode(encodedString);
          List<int> decodedzip = gzip.decode(zippedRoute);
          gpxData = utf8.decode(decodedzip);
          print(gpxData);

          var document = XmlDocument.parse(gpxData);

          final wptElements = document.findAllElements('wpt');
          // print(wptElements.length);

          for (final wptElement in wptElements) {
            final latAttr = wptElement.getAttribute('lat');
            // print(latAttr);
            final lonAttr = wptElement.getAttribute('lon');
            // print(lonAttr);

            if (latAttr != null && lonAttr != null) {
              final lat = double.tryParse(latAttr);
              final lon = double.tryParse(lonAttr);
              if (lat != null && lon != null) {
                LatLng latlng = LatLng(lat, lon);
                // print(latlng);
                route.add(latlng);
              }
            }
          }
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      debugPrint('오류 발생: $e');
    }
  }

  // GpxData parseGpx(gpxData) {
  //   final document = XmlDocument.parse(gpxData);
  //   final route = <LatLng>[];
  //   final wptElements = document.findAllElements('wpt');
  //
  //   for (final wptElement in wptElements) {
  //     final latAttr = wptElement.getAttribute('lat');
  //     final lonAttr = wptElement.getAttribute('lon');
  //
  //     if (latAttr != null && lonAttr != null) {
  //       final lat = double.tryParse(latAttr);
  //       final lon = double.tryParse(lonAttr);
  //       if (lat != null && lon != null) {
  //         LatLng latlng = LatLng(lat, lon);
  //         print(latlng);
  //         route.add(latlng);
  //       }
  //     }
  //   }
  //   return GpxData(route);
  // }

  // String reponseProcess() {
  //   String? jsondecodedString = Provider.of<HistoryProvider>(context, listen: false).responseBody;
  //   String? encodedString = jsondecodedString['gzipFile'];
  //   // setState(() {
  //   //   var encodedString = data['gzipFile'];
  //   //   List<int> zippedRoute = base64.decode(encodedString);
  //   //   GZipCodec gzip = GZipCodec();
  //   //   List<int> decodedzip = gzip.decode(zippedRoute);
  //   //   String gpxData = utf8.decode(decodedzip);
  //   //   print(gpxData);
  //   return ;
  // }

  String formatTime(seconds) {
    Duration duration = Duration(seconds: seconds);
    return DateFormat('HH:mm:ss').format(DateTime(0).add(duration));
  }

  @override
  Widget build(BuildContext context) {
    save(context);
    // GpxData gpx = parseGpx(gpxData);
    // List<LatLng> route = gpx.route;
    // route.sort((a, b) => a.latitude.compareTo(b.latitude)); // latitude 값을 비교하여 오름차순으로 정렬
    // var maxlat = route.sort((a, b) => a.latitude.compareTo(b.latitude)); // latitude 값을 비교하여 오름차순으로 정렬
    // var minlon = route.sort((a, b) => a.longitude.compareTo(b.longitude)); // latitude 값을 비교하여 오름차순으로 정렬
    // route.sort((a, b) => a.longitude.compareTo(b.longitude)); // latitude 값을 비교하여 오름차순으로 정렬

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
                  builder: (context) => const MyPage())
              );
            },
            child: Text(
              "Back",
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
                print("share button clicked");
                // print(gpxData);
                print(route[0]);
                print(route);
                // print(minlat);
                // print(maxlon);
                // print(route);
              },
              child: Text(
                "Share",
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
              initialCameraPosition: const CameraPosition(target: LatLng(37.801330, -122.403153), zoom: 5,
                // target: LatLng(((latmax - latmin) / 2 + latmin),
                //     ((lonmax - lonmin) / 2 + lonmin)), // 초기 지도 중심 좌표
                // zoom:
                // -log(max((latmax - latmin), (lonmax - lonmin)) / 256) / ln2,
              ),
              polylines: <Polyline>{
                for (int i = 0; i < route.length-1 ; i++)
                  Polyline(
                    polylineId: PolylineId("route_$i"),
                    color: Colors.blue,
                    width: 5,
                    points: [route[i], route[i+1]],
                  ),
              },
              //     <Polyline>{
              //   Polyline(
              //       polylineId: const PolylineId("route"),
              //       color: Colors.blue,
              //       width: 5,
              //       points: route,
              //   ),
              // },
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
                                  Text("Time",
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
                                  Text("Distance",
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
