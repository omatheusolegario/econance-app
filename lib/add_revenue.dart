import 'package:flutter/material.dart';

class AddRevenuePage extends StatefulWidget {
  const AddRevenuePage({super.key});

  @override
  State<AddRevenuePage> createState() => _AddRevenuePageState();
}

class _AddRevenuePageState extends State<AddRevenuePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Revenue"),
              ),
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          children: [
            const Text(
              "Você está no add revenue",
            ),
          ],
        ),
      ),
    );
  }
}
