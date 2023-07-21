import 'package:flutter/material.dart';
import '../utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
              height: 70,
            ),
            Text("Login",
              style: SafeGoogleFont(
                'Myanmar Khyay',
                fontSize: 27,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(
              width: double.infinity,
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40,0,40,0),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'your_email@example.com',
                      labelStyle: TextStyle(
                        color: Colors.black26,
                      ),
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email,
                        color: Colors.blue,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      // 입력 값이 변경될 때 실행되는 콜백 함수
                      // DB에 저장된 유저 정보랑 비교함
                      // value 매개변수에 입력된 텍스트가 전달됨
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'type your password',
                      labelStyle: TextStyle(
                        color: Colors.black26,
                      ),
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.key,
                        color: Colors.blue,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      // 입력 값이 변경될 때 실행되는 콜백 함수
                      // value 매개변수에 입력된 텍스트가 전달됨
                    },
                  )
                ],
              ),
            ),
            const SizedBox(
              width: double.infinity,
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(265, 0, 0, 0),
              child: ElevatedButton(
                onPressed: () {
                  print("Login button clicked");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                ),
                child: const Text("Log in",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    print("Forgot button clicked");
                  },
                  child: Text("Forgot Password?",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    print("signup button clicked");
                  },
                  child: Text("Sign up for Travis",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}


