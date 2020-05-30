import 'package:flutter/material.dart';
import 'HomeScreen.dart';


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(accentColor: Colors.black),
    title: 'Btech Buddy',
    home: HomeScreen(),
  ));
}
