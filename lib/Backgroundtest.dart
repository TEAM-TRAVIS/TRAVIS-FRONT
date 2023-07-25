import 'package:flutter/material.dart';
import 'package:background_location/background_location.dart';

class Background extends StatelessWidget {
  const Background({super.key});

  void start(){
    BackgroundLocation.startLocationService();
  }

  State<Background> createState() => BackgroundState();
}
class BackgroundState extends State<Background> {
  @override
  Widget build(BuildContext context) {
    return
  }
}