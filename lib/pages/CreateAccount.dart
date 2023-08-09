import 'package:flutter/material.dart';
import 'package:Travis/pages/Login.dart';
import 'package:Travis/pages/Signup.dart';
import 'package:Travis/utils.dart';

class CreateAccount extends StatelessWidget {
  const CreateAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            width: double.infinity,
            height: 50,
          ),
          Text("TRAVIS",
            style: SafeGoogleFont(
              'MuseoModerno',
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(
            width: double.infinity,
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 180, 0),
            child: Text("See your path\nand make trace\nin the world.",
              style: SafeGoogleFont(
                'Myanmar Khyay',
                fontSize: 27,
                fontWeight: FontWeight.w400,
                color: Colors.blue[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(
            width: double.infinity,
            height: 180,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(50,0,50,0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                      debugPrint("google button clicked");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(300, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      SizedBox(
                        width: 20,
                      ),
                      Text("continue with Google",
                        style: TextStyle(
                            fontWeight: FontWeight.w400
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 1.0, // 선의 높이
                      width: 100.0, // 선의 초기 너비
                      color: Colors.black26, // 선의 색상
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(50,0,50,0),
                      child: Text("OR",
                        style: TextStyle(
                          color: Colors.black26,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1.0,
                        color: Colors.black26,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    debugPrint("create account button clicked");
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => Signup()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(500, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0.0,
                  ),
                  child: const Text("Create an Account",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                ),
                const SizedBox(
                  width: double.infinity,
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Have an account already? ",
                      style: SafeGoogleFont("NanumGothic",
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => Login()));
                      },
                      child: Text('Log in',
                        style: SafeGoogleFont("NanumGothic",
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.blue,
                          ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}