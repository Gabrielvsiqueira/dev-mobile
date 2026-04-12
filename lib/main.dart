import 'package:alo_nene/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MedicalApp());
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alô, Nenê!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C5CBF)),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
