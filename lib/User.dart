import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String name;
  String email;
  String password;
  User(this.name, this.email, this.password);
}

class UserProvider extends ChangeNotifier {
  String? _userEmail;

  String? get userEmail => _userEmail;

  void setUserInfo(String email) {
    _userEmail = email;
    notifyListeners();
  }
}




