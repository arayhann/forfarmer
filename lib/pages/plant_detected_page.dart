import 'package:flutter/material.dart';

class PlantDetectedPage extends StatelessWidget {
  final List<dynamic> recognitions;
  const PlantDetectedPage({Key? key, required this.recognitions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: recognitions.length,
        itemBuilder: (context, index) => Text(
          recognitions[index]['label'],
        ),
      ),
    );
  }
}
