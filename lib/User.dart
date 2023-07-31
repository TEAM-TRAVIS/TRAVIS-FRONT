import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String name;
  String email;
  String password;
  User(this.name, this.email, this.password);
}

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners(); // 상태가 변경되었음을 리스너들에게 알립니다.
  }
}




