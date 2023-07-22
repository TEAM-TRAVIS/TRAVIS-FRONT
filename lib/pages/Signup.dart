import 'package:flutter/material.dart';
import 'package:myapp/pages/Login.dart';
import 'package:myapp/pages/User.dart';
import 'package:myapp/pages/SignupComplete.dart';
import '../utils.dart';
import 'package:http/http.dart' as http;

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  // final TextEditingController _nameController = TextEditingController(text: user.name);
  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  Future save() async {
    var res = await http.post("http://localhost:3000/signup" as Uri,
        headers: <String, String>{
          'Context-Type': 'application/json;charSet=UTF-8'
        },
        body: <String, String>{
          'name': user.name,
          'email': user.email,
          'password': user.password,
        });
    print(res.body);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  void dispose() {
    // _nameController.dispose();
    // _emailController.dispose();
    // _passwordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    _nameFocusNode.unfocus();
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
  }
  User user = User('', '', '');
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideKeyboard,
      child: Scaffold(
        body: Center(
          child: Column(
            key: _formKey,
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
              Text("Sign up",
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
                      controller: TextEditingController(text: user.name),
                      // focusNode: _nameFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        user.name = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter something';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: const TextStyle(
                          color: Colors.black26,
                        ),
                        hintText: 'Enter your name',
                        prefixIcon: const Icon(Icons.face,
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
                            borderSide: const BorderSide(color: Colors.red))
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      controller: TextEditingController(text: user.email),
                      // focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        user.email = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter something';
                        } else if (RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                          return null;
                        } else {
                          return 'Enter valid email';
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Email address',
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
                      controller: TextEditingController(text: user.password),
                      // focusNode: _passwordFocusNode,
                      obscureText: true,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        user.password = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password is required.";
                        } else if (value.length < 8) {
                          return "Password must be at least 8 characters long.";
                        } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                          return "Password must contain only English letters.";
                        } else{
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                    if (_formKey.currentState!.validate()) {
                      print("ok");
                      save();
                    } else {
                      print("not ok");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                  ),
                  child: const Text("Sign up",
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
                  const Text("By signing up, you agree that you accept our ",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      print("Terms of use button clicked");
                    },
                    child: Text("Terms of Use",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


