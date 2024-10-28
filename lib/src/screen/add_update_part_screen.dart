import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/exercise.dart';
import 'package:collection/collection.dart';
import 'add_update_workout_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'exercise_list_screen.dart'; // ExerciseListScreen import
import '../model/body_part.dart';
import 'package:uuid/uuid.dart';

class ExerciseScreen extends StatefulWidget {
  final AppLocalizations appLocalizations;
  final Function(Locale) setLocale;
  const ExerciseScreen(
      {Key? key, required this.appLocalizations, required this.setLocale})
      : super(key: key);

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
                    bodyPart: BodyPart(name: _bodyPartController.text),
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
    _bodyPartController.text = exercise.bodyPart.name;
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
                    bodyPart: BodyPart(name: _bodyPartController.text),
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
        // bodyPart 이름으로 그룹화
        final groupedExercises =
            groupBy(exerciseModel.exercises, (Exercise e) => e.bodyPart.name);

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.appLocalizations.type),
          ),
          body: ListView.builder(
            itemCount: groupedExercises.length,
            itemBuilder: (context, index) {
              final bodyPartName = groupedExercises.keys.elementAt(index);
              final exercises = groupedExercises[bodyPartName]!;

              return ListTile(
                title: Text('$bodyPartName (${exercises.length})'),
                onTap: () {
                  // 새로운 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseListScreen(
                        bodyPart:
                            BodyPart(name: bodyPartName), // BodyPart 객체 전달
                        exercises: exercises,
                        previousTitle: widget.appLocalizations.type,
                      ),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditExerciseDialog(exercises.first),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        for (var exercise in exercises) {
                          exerciseModel.deleteExercise(exercise.id);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddWorkoutScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
