import 'package:flutter/material.dart';
import 'homepage.dart';

class Start extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/bg1.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.4)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: Color(0xFF22304A), // Slightly lighter navy
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomePage()),
                  );
                },
                child: Text(
                  'Enter Library',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white, // White for contrast
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
