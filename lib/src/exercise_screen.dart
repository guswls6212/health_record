import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'exercise/exercise.dart';
import 'package:uuid/uuid.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({Key? key}) : super(key: key);

  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bodyPartController = TextEditingController();
  late String _selectedId;

  @override
  void dispose() {
    _nameController.dispose();
    _bodyPartController.dispose();
    super.dispose();
  }

  void _showAddExerciseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('운동 추가'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '운동 이름'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '운동 이름을 입력하세요.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _bodyPartController,
                  decoration: const InputDecoration(labelText: '신체 부위'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '신체 부위를 입력하세요.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newExercise = Exercise(
                    id: const Uuid().v4(),
                    name: _nameController.text,
                    bodyPart: _bodyPartController.text,
                  );
                  Provider.of<ExerciseModel>(context, listen: false)
                      .addExercise(newExercise);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  void _showEditExerciseDialog(Exercise exercise) {
    _nameController.text = exercise.name;
    _bodyPartController.text = exercise.bodyPart;
    _selectedId = exercise.id;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('운동 수정'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '운동 이름'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '운동 이름을 입력하세요.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _bodyPartController,
                  decoration: const InputDecoration(labelText: '신체 부위'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '신체 부위를 입력하세요.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final editedExercise = Exercise(
                    id: _selectedId,
                    name: _nameController.text,
                    bodyPart: _bodyPartController.text,
                  );
                  Provider.of<ExerciseModel>(context, listen: false)
                      .editExercise(editedExercise);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('수정'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseModel>(
      builder: (context, exerciseModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('운동 종류'),
          ),
          body: ListView.builder(
            itemCount: exerciseModel.exercises.length,
            itemBuilder: (context, index) {
              final exercise = exerciseModel.exercises[index];
              return ListTile(
                title: Text(exercise.name),
                subtitle: Text(exercise.bodyPart),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditExerciseDialog(exercise),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        exerciseModel.deleteExercise(exercise.id);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddExerciseDialog,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
