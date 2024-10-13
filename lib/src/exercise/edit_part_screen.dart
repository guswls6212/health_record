import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './exercise.dart';

class EditExerciseScreen extends StatefulWidget {
  final Exercise exercise;
  final int index;

  const EditExerciseScreen(
      {Key? key, required this.exercise, required this.index})
      : super(key: key);

  @override
  _EditExerciseScreenState createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _eventController.text = widget.exercise.event;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('운동 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(widget.exercise.part),
            TextField(
              controller: _eventController,
              decoration: InputDecoration(
                  labelText: '운동 부위', hintText: _eventController.text),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedExercise = Exercise(
                  part: widget.exercise.part,
                  event: _eventController.text,
                );
                Provider.of<ExerciseModel>(context, listen: false)
                    .updateExercise(widget.index, updatedExercise);
                Navigator.pop(context);
              },
              child: Text('수정'),
            ),
          ],
        ),
      ),
    );
  }
}
