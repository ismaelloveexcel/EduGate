import 'package:flutter/material.dart';

void main() {
  runApp(const EduGateApp());
}

class EduGateApp extends StatelessWidget {
  const EduGateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduGate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('EduGate'),
      ),
      body: const Center(
        child: Text('Welcome to EduGate!'),
      ),
    );
  }
}
