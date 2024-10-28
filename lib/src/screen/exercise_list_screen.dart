// exercise_list_screen.dart

import 'package:flutter/material.dart';
import 'package:health_record/src/model/body_part.dart';
import '../model/exercise.dart';

class ExerciseListScreen extends StatelessWidget {
  final BodyPart bodyPart;
  final List<Exercise> exercises;
  final String previousTitle;

  const ExerciseListScreen({
    Key? key,
    required this.bodyPart,
    required this.exercises,
    required this.previousTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bodyPart.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return ListTile(
            title: Text(exercise.name),
          );
        },
      ),
    );
  }
}
