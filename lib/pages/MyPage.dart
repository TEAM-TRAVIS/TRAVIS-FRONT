import 'dart:collection';
import 'dart:convert';
import 'package:Travis/pages/History.dart';
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

class HistoryProvider extends ChangeNotifier {
  String? _date;
  double? _dist;
  int? _time;

  String? get date => _date;
  double? get dist => _dist;
  int? get time => _time;

  void setDate(String date) {
    _date = date;
    notifyListeners();
  }

  void setDist(double dist) {
    _dist = dist;
    notifyListeners();
  }

  void setTime(int time) {
    _time = time;
    notifyListeners();
  }
}

class _MyPageState extends State<MyPage> with ChangeNotifier {
  ScrollController _scrollController = ScrollController();
  HashSet<String> selectedIndexes = HashSet();
  bool isMultiSelectionEnabled = false;
  bool _isLoading = false; // 로딩 상태 확인
  double toDist = 0.0;
  int toTime = 0;
  int page = 1;
  int limit = 7;
  List<dynamic> userData = [];
  // String getAllSummaryUrl = "http://44.218.14.132/gps/summary/all?page=$page&limit=$limit&city1=San%20Francisco&city2=New%20York";
  final String deleteOneSummaryUrl = "http://44.218.14.132/gps/summary";

  @override
  void initState() {
    super.initState();
    try {
      _scrollController.addListener(_scrollListener);
      getAllSummary(context);
    } catch (e) {
      debugPrint("컨텍스트 없는듯");
    }
  }

  void dispose() {
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      getAllSummary(context);
    }
  }

  Future getAllSummary(BuildContext contexts) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      try {
        var response = await http.post(Uri.parse("http://44.218.14.132/gps/summary/all?page=$page&limit=$limit"),
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, String>{
              'email': Provider.of<UserProvider>(context, listen: false).userEmail!,
            })
        ); //post

        print("MyPage Status Code: ${response.statusCode}");
        print(response.body);

        if (response.statusCode == 200) {
          try {
            var data = jsonDecode(response.body);
            setState(() {
              toDist = data['to_dist'].toDouble();
              toTime = data['to_time'];
              userData.addAll(data['userData']);
              page++;
              _isLoading = false;
            });
          } catch (e) {
            print(e);
          }
        }
      } catch (e) {
        debugPrint('오류 발생: $e');
      }
    }
  }

  Future deleteOneSummary(BuildContext context, String paramDate) async {
    try {
      var response = await http.delete(
        Uri.parse(deleteOneSummaryUrl),
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
      if (response.statusCode == 200) {
        getAllSummary(context);
        selectedIndexes.clear();
      }
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
                  print(Provider.of<HistoryProvider>(context, listen: false).time!);
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
                    String formattedOutput = index.replaceFirst('Z', '+00:00');
                    setState(() {
                      deleteOneSummary(context, formattedOutput);
                    });
                  }
                },
                icon: const Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 236, 246, 255),
                ),
              )
            : IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.map_rounded,
                  color: Color.fromARGB(255, 236, 246, 255),
                ),
              ),
              IconButton(
                onPressed: () {
                  getAllSummary(context);
                },
                icon: const Icon(
                  Icons.refresh,
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
                    controller: _scrollController,
                    itemCount: userData.length,
                    itemBuilder: (context, index) {
                      String date = userData[index]['date'];
                      double dist = userData[index]['dist'].toDouble();
                      int time = userData[index]['time'];
                      if (index < userData.length) {
                        return _routeList(context, date, dist, time);
                      } else if (_isLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return SizedBox.shrink();
                      }

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

  Widget _routeList(BuildContext context, date, dist, time) {
    return GestureDetector(
      onTap: () {
        if (isMultiSelectionEnabled) {
          doMultiSelection(date);
          print("selectedindexes: $selectedIndexes");
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const History(),
            ),
          );
          Provider.of<HistoryProvider>(context, listen: false).setDate(date);
          Provider.of<HistoryProvider>(context, listen: false).setDist(dist);
          Provider.of<HistoryProvider>(context, listen: false).setTime(time);
        }
      },
      onLongPress: () {
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
}
