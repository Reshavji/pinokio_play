import 'package:flutter/material.dart';

class AdsScreen extends StatelessWidget {
  const AdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Watch Ads 📺")),
      body: const Center(
        child: Text("Ads Screen", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}