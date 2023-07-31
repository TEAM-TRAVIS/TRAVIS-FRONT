import 'package:flutter/cupertino.dart';

class User with ChangeNotifier {
  String name;
  String email;
  String password;
  User(this.name, this.email, this.password);
}