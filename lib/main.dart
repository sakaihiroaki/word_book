import 'package:flutter/material.dart';
import 'package:myownfrashcard/db/database.dart';
import 'package:myownfrashcard/screens/home_screen.dart';

MyDatabase database;

void main() {
  database = MyDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '私だけの単語帳',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Lanobe',
      ),
      home: HomeScreen(),
    );
  }
}
