import 'package:flutter/material.dart';
import 'start.dart';
import 'addverse.dart';
import 'homepage.dart';

void main() {
  runApp(
    MaterialApp(
      home: Start(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/addverse': (context) => AddVersePage(),
        '/homepage': (context) => HomePage(),
      },
    ),
  );
}
