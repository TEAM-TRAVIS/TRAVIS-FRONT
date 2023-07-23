import 'package:flutter/material.dart';
import '../utils.dart';
import 'Signup.dart';
import 'package:Travis/User.dart';
import 'package:http/http.dart' as http;
import 'package:Travis/pages/Map.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideKeyboard,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
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
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          // 입력 값이 변경될 때 실행되는 콜백 함수
                          // DB에 저장된 유저 정보랑 비교함
                          // value 매개변수에 입력된 텍스트가 전달됨
                        },
                        validator: (value) {
                          // if ~~
                        },
                        decoration: InputDecoration(
                          labelText: 'your_email@example.com',
                          labelStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email,
                            color: Colors.blue,
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.blue)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.blue)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.red)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          // 입력 값이 변경될 때 실행되는 콜백 함수
                          // value 매개변수에 입력된 텍스트가 전달됨
                        },
                        validator: (value) {
                          // if ~~
                        },
                        decoration: InputDecoration(
                          labelText: 'type your password',
                          labelStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.key,
                            color: Colors.blue,
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.blue)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.blue)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.red)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.red)),
                        ),
                      ),
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
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => const Map()));
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
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const Signup()));
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
        ),
      ),
    );
  }
}


