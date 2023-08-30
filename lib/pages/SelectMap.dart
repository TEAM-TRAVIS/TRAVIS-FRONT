import 'dart:collection';
import 'dart:convert';
import 'package:Travis/Provider.dart';
import 'package:Travis/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:Travis/pages/AccumulatedHistory.dart';


class SelectMap extends StatefulWidget {
  const SelectMap({super.key});

  @override
  State<SelectMap> createState() => _SelectMapState();
}

class _SelectMapState extends State<SelectMap> with ChangeNotifier {
  bool _isLoading = false; // 로딩 상태 확인
  bool isMultiSelectionEnabled = false;
  HashSet<String> selectedIndexes = HashSet();
  List<dynamic> userData = [];
  List<String> testCity = ['San Francisco', 'Los Angeles', 'Seoul', 'Tokyo', 'London'];
  HashSet<String> citySet = HashSet();
  List<String> city = [];
  List<dynamic> classifiedRecord = [];
  
  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_scrollListener);
    getAllSummary(context);
  }

  Future getAllSummary(BuildContext context) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      try {
        var response = await http.post(Uri.parse("http://44.218.14.132/gps/summary/all"),
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, String>{
              'email': Provider.of<UserProvider>(context, listen: false).userEmail!,
            })
        ); //post

        print("SelectPage Status Code: ${response.statusCode}");
        // print("바디입니다. ${response.body}");

        if (response.statusCode == 200) {
          var decodedData = jsonDecode(response.body);
          setState(() {
            // print("뿌르를 ${decodedData['userData']}");
            userData = decodedData['userData'];
            // print("아아앙 ${userData[0]['city1']}");
            for (int i = 0; i < userData.length; i++) {
              String singleCity = userData[i]['city1'];
              citySet.add(singleCity);
            }
            city = citySet.toList();
            // print(city);
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('오류 발생: $e');
      }
    }
  }

  int classifyCity(int verticalIndex) {
    List<String> matchingCityList = [];
    for (int index = 0; index < userData.length; index++) {
      String singleCity = userData[index]['city1'];
      if (city[verticalIndex].contains(singleCity)) {
        matchingCityList.add(singleCity);
      }
    }
    return matchingCityList.length;
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Travis",
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
          leading:
            isMultiSelectionEnabled ?
            IconButton(
              onPressed: () {
                setState(() {
                  selectedIndexes.clear();
                  isMultiSelectionEnabled = false;
                });
              },
              icon: Icon(Icons.close)
            ) :
            null,
          actions: [
            TextButton(
              onPressed: () {
                getAllSummary(context);
                // print("유저 데이터입니다. $userData");
              },
              child: Text(
                "test",
                style: SafeGoogleFont(
                  'NanumGothic',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 236, 246, 255),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                List<String> selectedList = selectedIndexes.toList();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccumulatedHistory(selectedList: selectedList)));
              },
              child: Text(
                "show",
                style: SafeGoogleFont(
                  'NanumGothic',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 236, 246, 255),
                ),
              ),
            ),
          ],
        ),
        body: recordViewArrange(),
      ),
    );
  }

  /// 개별 도시별로 레이아웃 배치
  Widget recordViewArrange() {
    return Container(
      margin: EdgeInsets.all(50),
      child: Center(
        child: ListView.separated(
          itemCount: city.length,
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 20,
            );
          },
          itemBuilder: (context, verticalIndex) {
            return Column(
              children: [
                recordViewText(verticalIndex),
                recordView(verticalIndex),
              ],
            );
          },
        ),
      )
    );
  }

  /// 도시 이름과 구분선
  Widget recordViewText(int verticalIndex) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            /// input City name received from server
            city[verticalIndex],
            style: SafeGoogleFont(
              'MuseoModerno',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(
          color: Colors.black,
          thickness: 2,
        ),
      ],
    );
  }

  Widget recordView(int verticalIndex) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: classifyCity(verticalIndex), /// UserData[index] 처럼 사용
        separatorBuilder: (context, index) {
          return const SizedBox(
            width: 10,
          );
        },
        itemBuilder: (context, horizontalIndex) {
          int combinedIndex = verticalIndex * 10 + horizontalIndex;
          String city1 = userData[combinedIndex]['city1'];
          String date = userData[combinedIndex]['date'];
          String title = userData[combinedIndex]['title'];
          // print("으응으 ${city[verticalIndex]}");
          if (city[verticalIndex] == city1) {
            return Stack(
              children: [
                record(combinedIndex, date, title),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Visibility(
                    visible: isMultiSelectionEnabled,
                    child: Icon(
                      selectedIndexes.contains(date)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                      size: 30,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return null;
          }

        }
      ),
    );
  }

  Widget record(int combinedIndex, date, title) {
    return GestureDetector(
      onTap: () {
        if (isMultiSelectionEnabled) {
          doMultiSelection(date);
          print("selectedindexes: $selectedIndexes");
        } else {
          isMultiSelectionEnabled = true;
        }
      },
      child: Container(
        width: 200,
        color: Color.fromARGB(123, 234, 234, 234),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date,
            ),
            Text(
              title,
            ),
          ],
        ),
      ),
    );
  }

}


