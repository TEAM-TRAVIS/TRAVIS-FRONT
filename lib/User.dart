import 'package:flutter/cupertino.dart';
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
    notifyListeners(); // 상태가 변경되었음을 리스너들에게 알립니다.
  }
}




