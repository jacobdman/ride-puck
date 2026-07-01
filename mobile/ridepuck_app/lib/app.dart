import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class RidePuckApp extends StatelessWidget {
  const RidePuckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RidePuck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC41E3A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
