import 'package:gpx/gpx.dart';

class ResultArguments {
  final Gpx gpx;
  final int milliseconds;
  final double distance;

  // ResultArguments(this.gpx, this.milliseconds);
  ResultArguments(this.gpx, this.milliseconds, this.distance);
}