import 'package:flutter/material.dart';
import 'package:Travis/pages/Signup.dart';
import 'package:Travis/pages/Map.dart';
import 'package:Travis/User.dart';
import 'package:Travis/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  final String url = "http://172.17.96.1:3000/user/login";
  Future save() async {
    try {
      var res = await http.post(Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json;charSet=UTF-8'
          },
          body: jsonEncode(<String, String>{
            'email': user.email,
            'password': user.password,
          })); //post
      print(res.statusCode);
      print(res);
      if (res.statusCode == 302) {
        print("로그인 성공");
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => Map()));
      }
      else if (res.statusCode == 401) {
        print('로그인 실패');
        Fluttertoast.showToast(
          msg: "Check your email or password",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 3,
        );
      } else {
        print('요청에 실패하였습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

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

  User user = User('', '', '');
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
                          user.email = value;
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
                        obscureText: true,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          user.password = value;
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
                      save();
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


