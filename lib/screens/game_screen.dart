import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Play Games 🎮")),
      body: const Center(
        child: Text("Game Screen", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}