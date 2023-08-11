import 'package:gpx/gpx.dart';

class ResultArguments {
  final Gpx gpx;
  final int milliseconds;
  final double totalDistance;

  // ResultArguments(this.gpx, this.milliseconds);
  ResultArguments(this.gpx, this.milliseconds, this.totalDistance);
}