import 'package:Travis/utils.dart';
import 'package:flutter/material.dart';

class SelectMap extends StatefulWidget {
  const SelectMap({super.key});

  @override
  State<SelectMap> createState() => _SelectMapState();
}

class _SelectMapState extends State<SelectMap> {



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
          actions: [
            TextButton(
              onPressed: () {

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
        body:
    );
  }
}
