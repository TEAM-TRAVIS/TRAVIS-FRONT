import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:Travis/utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
//import 'package:background_location/background_location.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  late GoogleMapController mapController;
  LocationData? currentLocation; // LocationData 객체, LocationData는 사용자의 현재 위치 정보를 담는 클래스. 초기값으로 null을 할당하고 나중에 사용자의 위치 정보를 얻을때 값을 업데이트
  List<LatLng> routeCoordinates = []; // LatLng 객체들을 담는 리스트. 지도상의 경로나 마커 위치 등을 저장하는데 사용.
  // 이 클래스는 지도를 표시하고, 사용자의 현재 위치를 얻어서 currentLocation 변수에 저장하며, 지도 상의 경로를 routeCoordinates 리스트에 저장하는 기능을 수행.

  @override
  void initState() { // State 객체가 생성된 직후에 호출되는 특별한 초기화 메서드
    super.initState();
    routeCoordinates = [];
    initLocation();
  }

  void initLocation() async { // initstate에 의해서만 호출됨
    Location location = Location();  //Location은 gps 위치를 받아오는 '클래스' location은 객체 즉 객체 생성

    bool serviceEnabled; // 위치 서비스가 활성화되었는지 확인하는 변수
    PermissionStatus permissionGranted; // 위치 권한을 확인하는 변수

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
    // 위치 권한이 있는지 확인하고 없으면 위치 권한을 받는 코드

    location.onLocationChanged.listen((LocationData result) { // 위치 서비스를 통해 새로운 위치 정보를 받아옴
      setState(() { // setState() 메서드는 State 객체 내에서 상태를 변경할 때 사용되며 변경된 상태에 따라 UI가 다시 렌더링되어 반영됨. 그리고 currentLocation 변수와 routeCoordinates 리스트를 업데이트
        currentLocation = result; // 새로운 위치 정보를 result에 할당
        routeCoordinates.add(LatLng(result.latitude!, result.longitude!)); // result의 위도와 경도를 사용하여 LatLng 객체를 생성하고 이 객체를 routeCoordinates 리스트에 추가
      });
      if (mapController != null) { // GoogleMap이 떠 있을때만 작동하는 코드 블럭
        mapController.animateCamera( // 지도의 카메라를 새로운 위치로 이동. animateCamera 메서드는 부드러운 이동 모션
          CameraUpdate.newLatLng( // 카메라의 위치를 업데이트
            LatLng(result.latitude!, result.longitude!),
          ),
        );
      }
    }
  );
}

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
                mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // 초기 지도 중심 좌표
                zoom: 14.0,
              ),
              polylines: <Polyline>{
                Polyline(
                  polylineId: PolylineId("route"),
                  color: Colors.blue,
                  width: 5,
                  points: routeCoordinates,
                ),
              },
            ),
            SlidingUpPanel(
              minHeight: 70,
              maxHeight: 335,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: const [
                BoxShadow(
                    blurRadius: 0
                ),
              ],
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
                        print("start button clicked");
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 41, 91, 242)),
                        minimumSize: MaterialStateProperty.all(const Size(double.infinity, 38)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                      child: Text("Start",
                        style: SafeGoogleFont(
                          'NanumGothic',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            ),
            Positioned(
              top: 10,
              left: 20,
              child: Text(
                '현재 위치: ${currentLocation?.latitude}, ${currentLocation?.longitude}, ${currentLocation?.elapsedRealtimeNanos}',
                style: const TextStyle(fontSize: 15,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
