import 'package:flutter/material.dart';
import '../utils.dart';
import '../pages/Map.dart';

class SignupComplete extends StatelessWidget {
  const SignupComplete({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.travel_explore,
                size: 40,
                color: Color(0xFF295BF2),
              ),
              const SizedBox(
                width: double.infinity,
                height: 20,
              ),
              Text("Welcome!",
                style: SafeGoogleFont(
                  'Myanmar Khyay',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(
                width: double.infinity,
                height: 20,
              ),
              Text("Hope you enjoy travel",
                style: SafeGoogleFont(
                  'Myanmar Khyay',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(
                width: double.infinity,
                height: 20,
              ),
              Text("with Travis",
                style: SafeGoogleFont(
                  'Myanmar Khyay',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(
                width: double.infinity,
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  print("Let's go button clicked");
                  Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const Map()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
                  ),
                ),
                child: const Text("Let's go!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
