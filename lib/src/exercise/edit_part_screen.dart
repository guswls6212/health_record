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
  TextEditingController _partController = TextEditingController();
  TextEditingController _eventController = TextEditingController();
  List<String> _eventList = [];

  @override
  void initState() {
    super.initState();
    // _eventController.text = widget.exercise.event.join(', ');
    _eventList = List.from(widget.exercise.event);
  }

  void _addToList() {
    final newEvent = _eventController.text.trim();
    if (newEvent.isNotEmpty && !_eventList.contains(newEvent)) {
      setState(() {
        _eventList.add(newEvent);
      });
      _eventController.clear();
    }
  }

  void _removeFromList(int index) {
    setState(() {
      _eventList.removeAt(index);
    });
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
              decoration:
                  InputDecoration(labelText: '운동 부위', hintText: '운동을 입력하세요'),
            ),
            ElevatedButton(
              onPressed: _addToList,
              child: Text('추가'),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _eventList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_eventList[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeFromList(index),
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                final updatedExercise = Exercise(
                  part: widget.exercise.part,
                  event: _eventList,
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
