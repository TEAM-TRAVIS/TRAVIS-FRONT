import 'package:Travis/User.dart';
import 'package:Travis/pages/MyPage.dart';
import 'package:flutter/material.dart';
import 'package:Travis/pages/Result.dart';
import 'package:Travis/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:gpx/gpx.dart';
import 'package:Travis/Arguments.dart';

List<LatLng> routeCoordinates = []; // LatLng 객체들을 담는 리스트. 지도상의 경로나 마커 위치 등을 저장하는데 사용.
var latmin = 400.0 ,latmax = -400.0 ,lonmin = 400.0 ,lonmax = -400.0;
Gpx gpx = Gpx();

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  MapState createState() => MapState();
}

class MapState extends State<Map> with ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late GoogleMapController mapController;
  late Timer timer;
  DateTime? currentBackPressTime;
  int milliseconds = 0;
  double totalDistance = 0.0;
  bool isTracking = false;
  bool isRunning = false;
  static const double fabHeightClose = 100;
  double fabHeight = fabHeightClose;
  String currentRegion = "";
  LocationData? currentLocation = LocationData.fromMap({
    "latitude": 37.7749,
    "longitude": -122.4194,
  });

  @override
  void initState() {
    super.initState();
    routeCoordinates = [];
    initLocation();
  }

  void initLocation() async {
    Location location = Location();
    bool serviceEnabled;
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

    location.changeSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
    location.onLocationChanged
        .throttle((_) => TimerStream(true, const Duration(seconds: 1)))
        .listen((LocationData locationData) async {
      setState(() {
        currentLocation = locationData;
        if (isTracking) {
          if (isRunning) {
            if (latmin > locationData.latitude!)
              latmin = locationData.latitude!;
            if (lonmin > locationData.longitude!)
              lonmin = locationData.longitude!;
            if (latmax < locationData.latitude!)
              latmax = locationData.latitude!;
            if (lonmax < locationData.longitude!)
              lonmax = locationData.longitude!;

            gpx.wpts.add(
              Wpt(
                lat: locationData.latitude!,
                lon: locationData.longitude!,
                time: DateTime.now(),
              )
            );

            LatLng currentLatLng =
              LatLng(locationData.latitude!, locationData.longitude!);
            if (routeCoordinates.isNotEmpty) {
              totalDistance += calculateDistance(routeCoordinates.last, currentLatLng);
            }
            routeCoordinates.add(currentLatLng);
          }
        }
      });
      mapController.animateCamera(
        CameraUpdate.newLatLng(
            LatLng(locationData.latitude!, locationData.longitude!)),
      );
    });
  }

  double calculateDistance(LatLng latLng1, LatLng latLng2) {
    double distanceInMeters = geolocator.Geolocator.distanceBetween(
      latLng1.latitude,
      latLng1.longitude,
      latLng2.latitude,
      latLng2.longitude,
    );
    return distanceInMeters;
  }

  double calculateTotalDistance() {
    for (int i = 0; i < routeCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(routeCoordinates[i], routeCoordinates[i + 1]);
    }
    return totalDistance;
  }

  String formatTime() {
    Duration duration = Duration(milliseconds: milliseconds);
    return DateFormat('HH:mm:ss').format(DateTime(0).add(duration));
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 10), (Timer timer) {
      setState(() {
        milliseconds += 10;
      });
    });
  }

  void stopTimer() {
    timer.cancel();
  }

  void toggleTimer() {
    setState(() {
      isRunning = !isRunning;
      if (isRunning) {
        startTimer();
      } else {
        stopTimer();
      }
    });
  }

  void _startTracking() {
    setState(() {
      routeCoordinates.clear();
      isTracking = true;
      totalDistance = 0.0;
    });
  }

  void _stopTracking() {
    setState(() {
      isTracking = false;
      totalDistance = calculateTotalDistance();
    });
    ResultArguments args = ResultArguments(gpx, milliseconds, totalDistance);
    if (totalDistance != 0 && milliseconds != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Result(),
          settings: RouteSettings(arguments: args),
        ),
      );
    } else if (totalDistance == 0 || milliseconds == 0) {
      // Fluttertoast.showToast(
      //   msg: "Invalid data entered!",
      //   toastLength: Toast.LENGTH_SHORT,
      //   timeInSecForIosWeb: 3,
      // );
      // setState(() {
      //   milliseconds = 0;
      // });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Result(),
          settings: RouteSettings(arguments: args),
        ),
      );
    }
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      const msg = "Press back again to exit app.";
      Fluttertoast.showToast(msg: msg);
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    double panelHeightOpen = MediaQuery.of(context).size.height * 0.3;
    double panelHeightClose = MediaQuery.of(context).size.height * 0.1;
    return WillPopScope(
      onWillPop: onWillPop,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          key: scaffoldKey,
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
            leading: IconButton(
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
              icon: Icon(
                Icons.menu,
                color: Colors.blue,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  debugPrint("settings button clicked");
                },
                icon: Icon(
                  Icons.settings,
                  color: Colors.blue[500],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => const MyPage()
                      ));
                },
                icon: Icon(Icons.home,
                  color: Colors.blue[500],
                ),
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    "Name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(Provider.of<UserProvider>(context, listen: false).userEmail!),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/1661526553810-3.jpg'),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ListTile(
                    leading: Icon(Icons.feed_outlined),
                    title: Text(
                      'Feed',
                    ),
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(
                      //     builder: (context) => Feed()));
                    },
                    trailing: Icon(Icons.add),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      'Profile Setting',
                    ),
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(
                      //     builder: (context) => Feed()));
                    },
                    trailing: Icon(Icons.add),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: ListTile(
                    leading: Icon(Icons.question_answer),
                    title: Text(
                      'Q&A',
                    ),
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(
                      //     builder: (context) => Feed()));
                    },
                    trailing: Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.7749, -122.4194), // 초기 지도 중심 좌표
                  zoom: 15.0,
                ),
                polylines: <Polyline>{
                  if (isTracking)
                    if (isRunning)
                      Polyline(
                          polylineId: const PolylineId("route"),
                          color: Colors.blue,
                          width: 8,
                          points: routeCoordinates
                      ),
                },
                zoomControlsEnabled: false,
                markers: <Marker>{
                  Marker(
                    markerId: const MarkerId('currentLocation'),
                    position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                  ),
                },
              ),
              Positioned(
                right: 20,
                bottom: fabHeight,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    mapController.animateCamera(
                      CameraUpdate.newLatLng(
                          LatLng(currentLocation!.latitude!, currentLocation!.longitude!)),
                    );
                  },
                  child: Icon(
                    Icons.gps_fixed,
                    color: Colors.blue,
                  ),
                ),
              ),
              SlidingUpPanel(
                minHeight: panelHeightClose,
                maxHeight: panelHeightOpen,
                onPanelSlide: (position) => setState(() {
                  final panelMaxScrollExtent = panelHeightOpen - panelHeightClose;
                  fabHeight = position * panelMaxScrollExtent + fabHeightClose;
                }),
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
                        height: 20,
                      ),
                      isTracking? // isTracking == true -> 트래킹 중일때는 pause 버튼, stop 버튼
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  toggleTimer();
                                },
                                style: isRunning?
                                  ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 3, 43, 166)),
                                    minimumSize: MaterialStateProperty.all(const Size(100, 38)),
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))) :
                                  ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 83, 123, 248)),
                                      minimumSize: MaterialStateProperty.all(const Size(100, 38)),
                                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                                child: isRunning?
                                  Text("Pause",
                                    style: SafeGoogleFont(
                                      'MuseoModerno',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ):
                                  Text("Resume",
                                    style: SafeGoogleFont(
                                      'MuseoModerno',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  toggleTimer();
                                  _stopTracking();

                                  gpx.metadata = Metadata(
                                    name: Provider.of<UserProvider>(context, listen: false).userEmail,
                                    desc: (milliseconds~/1000).toString(),
                                    keywords: (totalDistance/1000).toString(),
                                    bounds: Bounds(
                                      minlat: latmin,
                                      minlon: lonmin,
                                      maxlat: latmax,
                                      maxlon: lonmax,
                                    ),
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 3, 43, 166)),
                                  fixedSize: MaterialStateProperty.all(const Size(100, 38)),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                                child: Text("Stop",
                                  style: SafeGoogleFont(
                                    'MuseoModerno',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ) :
                        ElevatedButton(
                          onPressed: () {
                            toggleTimer();
                            _startTracking();
                          },
                          style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 41, 91, 241)),
                                  minimumSize: MaterialStateProperty.all(const Size(double.infinity, 38)),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                          child: Text("Start",
                            style: SafeGoogleFont(
                              'MudeoModerno',
                              fontSize: 15,
                              fontWeight: FontWeight.w500
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
                                        formatTime(),
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
                                      isTracking ?
                                      Text('${(totalDistance/1000).toStringAsFixed(1)}km',
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