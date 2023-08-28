import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';

class UserProvider extends ChangeNotifier {
  String? _userEmail;

  String? get userEmail => _userEmail;

  void setUserInfo(String email) {
    _userEmail = email;
    notifyListeners();
  }
}

class HistoryProvider extends ChangeNotifier {
  String? _date;
  double? _dist;
  int? _time;

  String? get date => _date;
  double? get dist => _dist;
  int? get time => _time;

  void setDate(String date) {
    _date = date;
    notifyListeners();
  }

  void setDist(double dist) {
    _dist = dist;
    notifyListeners();
  }

  void setTime(int time) {
    _time = time;
    notifyListeners();
  }
}

class IsTrackingProvider extends ChangeNotifier {
  bool? _isTracking;

  bool? get isTracking => _isTracking;

  void setIsTracking(bool isTracking) {
    _isTracking = isTracking;
    notifyListeners();
  }
}

class RecordInfoProvider extends ChangeNotifier {
  int? _milliseconds;
  double? _totalDistance;
  Gpx? _gpx;

  int? get milliseconds => _milliseconds;
  double? get totalDistance => _totalDistance;
  Gpx? get gpx => _gpx;

  void setRecordInfo(int milliseconds, double totalDistance, Gpx gpx) {
    _milliseconds = milliseconds;
    _totalDistance = totalDistance;
    _gpx = gpx;
    notifyListeners();
  }
}