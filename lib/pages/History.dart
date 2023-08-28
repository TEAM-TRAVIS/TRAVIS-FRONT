import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:Travis/Provider.dart';
import 'package:Travis/pages/Map.dart';
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
  TextEditingController _titleEditingController = TextEditingController();
  TextEditingController _contentEditingController = TextEditingController();
  late GoogleMapController mapController;
  late String? gpxData;
  List<LatLng> route = [];
  final String getGPSUrl = "http://44.218.14.132/gps/detail";
  final String getOneSummaryUrl = "http://44.218.14.132/gps/summary";
  final String updateSummaryUrl = "http://44.218.14.132/gps/summary/update";
  String title = "";
  String content = "";
  String public = "";
  bool isModifing = false;
  bool isPublic = false;

  @override
  void initState() {
    super.initState();
    getGPS(context);
    getOneSummary(context);
    route = [];
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
    _titleEditingController.dispose();
    _contentEditingController.dispose();
  }

  Future getGPS(BuildContext context) async {
    try {
      var response = await http.post(
        Uri.parse(getGPSUrl),
        headers: <String, String>{
          'Content-Type': 'application/json;charSet=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': Provider.of<UserProvider>(context, listen: false).userEmail!,
          'date': Provider.of<HistoryProvider>(context, listen: false).date!,
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
            isPublic = data['oneSummary']['isPublic'] as bool;
            print(isPublic);
          });
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      debugPrint('오류 발생: $e');
    }
  }

  Future updateSummary(BuildContext context) async {
    try {
      var response = await http.post(Uri.parse(updateSummaryUrl),
        headers: <String, String>{
          'Content-Type': 'application/json;charSet=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': Provider.of<UserProvider>(context, listen: false).userEmail!,
          'date': Provider.of<HistoryProvider>(context, listen: false).date!.replaceFirst('Z', '+00:00'),
          'title' : title,
          'content' : content,
          'isPublic' : isPublic ? "true":"false",
        }),
      ); //post
      print("update Status Code: ${response.statusCode}");
      print(response.body);
    } catch (e) {
      debugPrint('오류 발생: $e');
    }
  }

  void parseGpx(gpxData) {
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
  }

  String formatTime(seconds) {
    Duration duration = Duration(seconds: seconds);
    return DateFormat('HH:mm:ss').format(DateTime(0).add(duration));
  }

  void _toggleEditing() {
    setState(() {
      isModifing = !isModifing;
      if (isModifing) {
        _titleEditingController.text = title;
        _contentEditingController.text = content;
      }
    });
  }

  void _updateText() {
    setState(() {
      title = _titleEditingController.text;
      content = _contentEditingController.text;
      isModifing = false;
    });
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
                  print("share button clicked");
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
                minHeight: MediaQuery.of(context).size.height * 0.1,
                maxHeight: MediaQuery.of(context).size.height * 0.5,
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
                      Stack(
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: isModifing
                              ? TextButton(
                                  onPressed: () {
                                    _updateText();
                                    updateSummary(context);
                                    setState(() {});
                                  },
                                  child: Text(
                                    "Update",
                                    style: SafeGoogleFont(
                                      'NanumGothic',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 239, 38, 38),
                                    ),
                                  ),
                                )
                              : TextButton(
                                  onPressed: () {
                                    _toggleEditing();
                                    setState(() {});
                                  },
                                  child: Text(
                                    "Modify",
                                    style: SafeGoogleFont(
                                      'NanumGothic',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                          ),
                        ],
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
                                    formatTime(Provider.of<HistoryProvider>(context, listen: false).time),
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
                                    "${Provider.of<HistoryProvider>(context, listen: false).dist}km",
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
                        child: isModifing
                          ? Container(
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
                                    controller: _titleEditingController,
                                    // focusNode: _emailFocusNode,
                                    onChanged: (value) {
                                      title = value;
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
                                    controller: _contentEditingController,
                                    // focusNode: _emailFocusNode,
                                    onChanged: (value) {
                                      content = value;
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
                            )
                          : Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            margin: EdgeInsets.only(bottom: 20, left: 1, right: 1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                title == ""
                                ? Text(
                                    "Enter title!",
                                    style: SafeGoogleFont(
                                      'NanumGothic',
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(
                                    title,
                                    style: SafeGoogleFont(
                                      'NanumGothic',
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                const Divider(
                                  color: Color.fromARGB(255, 217, 217, 217),
                                  height: 1,
                                  thickness: 1,
                                ),
                                content == ""
                                ? Text(
                                    "Enter content!",
                                    style: SafeGoogleFont(
                                      'NanumGothic',
                                      fontSize: 20,
                                    ),
                                  )
                                : Text(
                                    content,
                                    style: SafeGoogleFont(
                                      'NanumGothic',
                                      fontSize: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: isModifing ? EdgeInsets.only(bottom: 0) : EdgeInsets.only(bottom: 10),
                          width: 110,
                          child: isModifing ? publicSwitch() : publicText(),
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
    );
  }

  Widget publicSwitch() {
    return Stack(
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
    );
  }

  Widget publicText() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            isPublic ? "Public" : "Private",
            style: SafeGoogleFont(
              'NanumGothic',
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: isPublic ? Colors.blue : Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
