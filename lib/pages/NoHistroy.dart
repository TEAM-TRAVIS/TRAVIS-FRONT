import 'package:Travis/pages/MyPage.dart';
import 'package:Travis/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NoHistory extends StatefulWidget {
  const NoHistory({super.key});

  @override
  State<NoHistory> createState() => _NoHistoryState();
}

class _NoHistoryState extends State<NoHistory> with ChangeNotifier {

  final String url = "http://44.218.14.132/gps/detail";
  // Future save(BuildContext contexts) async {
  //   try {
  //     var response = await http.post(
  //       Uri.parse(url),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json;charSet=UTF-8',
  //       },
  //       body: jsonEncode(<String, String>{
  //         'email': Provider.of<UserProvider>(context, listen: false).userEmail!,
  //         'date': Provider.of<DateProvider>(context, listen: false).date!,
  //       }),
  //     ); //post
  //
  //     print(response.statusCode);
  //
  //     if (response.statusCode == 201) {
  //       GZipCodec gzip = GZipCodec();
  //       print("History 페이지에 들어왔습니다.");
  //       try {
  //         print("네 반갑습니다");
  //         var data = jsonDecode(response.body);
  //         var encodedString = data['gzipFile'];
  //         List<int> zippedRoute = base64.decode(encodedString);
  //         List<int> decodedzip = gzip.decode(zippedRoute);
  //         gpxData = utf8.decode(decodedzip);
  //         print("History 페이지의 gpxData: $gpxData");
  //         parseGpx(gpxData);
  //       } catch (e) {
  //         print(e);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('오류 발생: $e');
  //   }
  // }

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
              fontSize: 21,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MyPage()));
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
                print("test button clicked");
              },
              child: Text(
                "test",
                style: SafeGoogleFont(
                  'NanumGothic',
                  fontSize: 15,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Text(
                "Oops!",
                style: SafeGoogleFont(
                  "NanumGothic",
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}
