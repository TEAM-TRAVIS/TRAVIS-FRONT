import 'dart:convert';
import 'package:Travis/pages/History.dart';
import 'package:Travis/pages/Map.dart';
import 'package:Travis/User.dart';
import 'package:Travis/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with ChangeNotifier {
  double toDist = 0.0;
  int toTime = 0;
  List<dynamic> userData = [];

  @override
  void initState() {
    super.initState();
    try {
      save(context);
    } catch (e) {
      debugPrint("컨텍스트 없는듯");
    }
  }

  final String url = "http://172.17.96.1:3000/gps/summary";
  Future save(BuildContext contexts) async {
    try {
      var response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json;charSet=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': Provider.of<UserProvider>(context, listen: false).userEmail!,
        }),
      ); //post

      print("마이페이지 post");
      print(response.statusCode);
      print(response.body);
      print("------------------");
      // var data = jsonDecode(response.body);
      // print(data);
      // print(data.runtimeType);
      // toDist = data['to_dist'];
      // toTime = data['to_time'];
      // print(toDist);
      // print(toTime);

      if (response.statusCode == 200) {
        print("MyPage에 들어왔습니다.");
        try {
          var data = jsonDecode(response.body);
          setState(() {
            toDist = data['to_dist'];
            toTime = data['to_time'];
            print("제대로 들어왔다");

            userData = data['userData'];
            // print(userData);
            // print(userData.length);
            // print(userData[1]);
            // print(userData[1]['date']);

          });
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      debugPrint('오류 발생: $e');
    }
    // response를 건별로 분리해 새로운 변수에 담고 그것을 리스트뷰에 각각 담는다.
  }

  String formatTime(seconds) {
    Duration duration = Duration(seconds: seconds);
    return DateFormat('HH:mm:ss').format(DateTime(0).add(duration));
  }

  String dateChange(dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }

  String timeChange(dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Travis",
            style: SafeGoogleFont(
              'MuseoModerno',
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 236, 246, 255),
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 41, 91, 242),
          elevation: 0.0,
          leading: IconButton(
            onPressed: () {
              debugPrint("Menubutton clicked");
            },
            icon: const Icon(
              Icons.menu,
              color: Color.fromARGB(255, 236, 246, 255),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const Map()));
              },
              icon: const Icon(
                Icons.home,
                color: Color.fromARGB(255, 236, 246, 255),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                height: (MediaQuery.of(context).size.height)/4,
                color: const Color.fromARGB(255, 41, 91, 242),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          "${Provider.of<UserProvider>(context).userEmail!.split("@")[0]},",
                          // DB에서 유저 이름 가져와야함.
                          style: SafeGoogleFont(
                            'MuseoModerno',
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 236, 246, 255),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(top: 25, bottom: 3, left: 30, right: 30),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "Your travel distance",
                                      textAlign: TextAlign.left,
                                      style: SafeGoogleFont(
                                        'MuseoModerno',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(255, 236, 246, 255),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "${toDist.toString()}km",
                                          // "0km",
                                          style: SafeGoogleFont(
                                            'MuseoModerno',
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: const Color.fromARGB(255, 236, 246, 255),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(top: 3, bottom: 20, left: 30, right: 30),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "Your travel time",
                                      style: SafeGoogleFont(
                                        'MuseoModerno',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(255, 236, 246, 255),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      formatTime(toTime),
                                      // "00:00:00",
                                      style: SafeGoogleFont(
                                        'MuseoModerno',
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(255, 236, 246, 255),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView.builder(
                    itemCount: userData.length,
                    itemBuilder: (context, index) {
                      String date = userData[index]['date'];
                      var dist = userData[index]['dist'];
                      var time = userData[index]['time'];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const History(),
                                  settings: RouteSettings(arguments: date),
                                ),
                          );
                          // print("뿔흐르를");
                          //debugPrint(userData[index]);
                        },
                        child: Card(
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 100,
                                height: 100,
                                // child: Image.asset(imageList[index]),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Column(
                                  children: [
                                    Text(
                                      "${dateChange(date)} ${timeChange(date)}",
                                      // userData['date'],
                                      // "Aug/06/2023 15:37:30",
                                      style: SafeGoogleFont(
                                        'MuseoModerno',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${dist}km",
                                      // userData['date'],
                                      // "Aug/06/2023 15:37:30",
                                      style: SafeGoogleFont(
                                        'MuseoModerno',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      formatTime(time),
                                      // userData['date'],
                                      // "Aug/06/2023 15:37:30",
                                      style: SafeGoogleFont(
                                        'MuseoModerno',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
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
