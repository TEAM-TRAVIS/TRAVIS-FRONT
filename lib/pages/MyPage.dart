import 'dart:collection';
import 'dart:convert';
import 'package:Travis/pages/History.dart';
import 'package:Travis/pages/Map.dart';
import 'package:Travis/User.dart';
import 'package:Travis/pages/NoHistroy.dart';
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

class DateProvider extends ChangeNotifier {
  String? _date;

  String? get date => _date;

  void setDate(String date) {
    _date = date;
    notifyListeners();
  }
}

class _MyPageState extends State<MyPage> with ChangeNotifier {
  HashSet<String> selectedIndexes = HashSet();
  bool isMultiSelectionEnabled = false;
  double toDist = 0.0;
  int toTime = 0;
  List<dynamic> userData = [];
  final String url = "http://44.218.14.132/gps/summary";

  @override
  void initState() {
    super.initState();
    try {
      save(context);
    } catch (e) {
      debugPrint("컨텍스트 없는듯");
    }
  }

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
      print("------------------");

      if (response.statusCode == 200) {
        print("MyPage에 들어왔습니다.");
        try {
          var data = jsonDecode(response.body);
          setState(() {
            toDist = data['to_dist'].toDouble();
            toTime = data['to_time'];
            print("제대로 들어왔다");
            userData = data['userData'];
          });
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      debugPrint('오류 발생: $e');
    }
  }

  Future deleteOneSummary(BuildContext context, String paramDate) async {
    try {
      var response = await http.delete(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json;charSet=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': Provider.of<UserProvider>(context, listen: false).userEmail!,
          'date': paramDate,
        }),
      ); //post
      print(response.statusCode);
      print(response.body);
    } catch (e) {
      debugPrint('오류 발생: $e');
    }
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

  void doMultiSelection(String string) {
    if (isMultiSelectionEnabled) {
      if (selectedIndexes.contains(string)) {
        selectedIndexes.remove(string);
      } else {
        selectedIndexes.add(string);
      }
      setState(() {});
    }
  }

  String getSelectedIndexesCount() {
    return selectedIndexes.isNotEmpty
        ? selectedIndexes.length.toString() + " item selected"
        : "No item selected";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            isMultiSelectionEnabled
            ? getSelectedIndexesCount() :
            "Travis",
            style: SafeGoogleFont(
              'MuseoModerno',
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 236, 246, 255),
            ),
          ),
          centerTitle: true,
          backgroundColor:
            isMultiSelectionEnabled
            ? const Color.fromARGB(255, 224, 20, 20)
            : const Color.fromARGB(255, 41, 91, 242),
          elevation: 0.0,
          leading:
            isMultiSelectionEnabled
            ? IconButton(
                onPressed: () {
                  setState(() {
                    selectedIndexes.clear();
                    isMultiSelectionEnabled = false;
                  });
                },
                icon: Icon(Icons.close)
              )
            : IconButton(
                onPressed: () {
                  debugPrint("Menubutton clicked");
                },
                icon: const Icon(
                  Icons.menu,
                  color: Color.fromARGB(255, 236, 246, 255),
                ),
              ),
          actions: [
            isMultiSelectionEnabled
            ? IconButton(
                onPressed: () {
                  print("delete button clicked");
                  for (var index in selectedIndexes) {
                    deleteOneSummary(context, index);
                  }
                  setState(() {});
                },
                icon: const Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 236, 246, 255),
                ),
              )
            : IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const Map()));
                },
                icon: const Icon(
                  Icons.home,
                  color: Color.fromARGB(255, 236, 246, 255),
                ),
              )
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
                          "${Provider.of<UserProvider>(context).userEmail!.split("@")[0]}",
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
                          if (isMultiSelectionEnabled) {
                            doMultiSelection(date);
                            print("selectedindexes: $selectedIndexes");
                          } else {
                            if (dist != 0 && time != 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const History(),
                                ),
                              );
                              Provider.of<DateProvider>(context, listen: false)
                                  .setDate(date);
                            } else if (dist == 0 || time == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NoHistory(),
                                ),
                              );
                            }
                          }
                        },
                        onLongPress: () {
                          print("clicked");
                          isMultiSelectionEnabled = true;
                          doMultiSelection(date);
                          print("selectedindexes: $selectedIndexes");
                        },
                        child: Card(
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 200,
                                    child: Column(
                                      children: [
                                        Text(
                                          "${dateChange(date)} ${timeChange(date)}",
                                          style: SafeGoogleFont(
                                            'MuseoModerno',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${dist}km",
                                          style: SafeGoogleFont(
                                            'MuseoModerno',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          formatTime(time),
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
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Visibility(
                                  visible: isMultiSelectionEnabled,
                                  child: Icon(
                                    selectedIndexes.contains(date)
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    size: 30,
                                    color: Colors.red,
                                  ),
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
