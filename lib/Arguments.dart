import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';

class ResultArguments {
  final Gpx gpx;
  final int milliseconds;

  ResultArguments(this.gpx, this.milliseconds);
}