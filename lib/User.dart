import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String name;
  String email;
  String password;
  User(this.name, this.email, this.password);
}


//   void updateUserInfo({String? name, String? email, String? password}) {
//     this.name = name ?? this.name;
//     this.email = email ?? this.email;
//     this.password = password ?? this.password;
//     notifyListeners();
//   }
// }