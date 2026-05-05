import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Tasks 🧾")),
      body: const Center(
        child: Text("Tasks Screen", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}