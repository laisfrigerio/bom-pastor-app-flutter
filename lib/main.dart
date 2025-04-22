import 'package:bom_pastor_app/screens/classrooms/list_classroom_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bom Pastor',
      home: const ListClassRoomScreen(title: 'Instituto Bom Pastor'),
      debugShowCheckedModeBanner: false,
    );
  }
}
