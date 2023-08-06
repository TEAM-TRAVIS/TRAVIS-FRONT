import 'dart:convert';

import 'package:Travis/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {

  final String url = "http://172.17.96.1:3000/gps/save";
  Future save(String email) async {
    try {
      var response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json;charSet=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      ); //post
      print(response.statusCode);
      print(response.body);
    } catch (e) {
      print('오류 발생: $e');
    }
    // response를 건별로 분리해 새로운 변수에 담고 그것을 리스트뷰에 각각 담는다.

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
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                height: (MediaQuery.of(context).size.height)/4,
                color: const Color.fromARGB(255, 41, 91, 242),
                child: const Row(
                  children: [
                    Column(
                      children: [
                        // Text(
                        //
                        // ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        // body:
      ),
    );
  }
}
