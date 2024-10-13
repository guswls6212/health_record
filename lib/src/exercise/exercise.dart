import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';
import './edit_part_screen.dart';

@JsonSerializable()
class Exercise {
  final String part;
  final String event;

  Exercise({required this.part, required this.event});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      part: json['part'] as String, // null 체크 및 타입 변환 추가
      event: json['event'] as String,
    );
  }

  static Map<String, dynamic> toJson(Exercise value) =>
      {'part': value.part, 'event': value.event};
}

class ExerciseModel extends ChangeNotifier {
  //싱글톤 처리
  static final ExerciseModel _instance = ExerciseModel._internal();
  factory ExerciseModel() => _instance;
  ExerciseModel._internal();
  //싱글톤 처리

  List<Exercise> _exercises = [];

  List<Exercise> get exercises => _exercises;

  Future<void> loadExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = prefs.getString('exercises');
    print(encodedData);
    if (encodedData != null) {
      final Map<String, dynamic> exerciseJson = jsonDecode(encodedData);
      final List<dynamic> decodedData = exerciseJson['exercise'];
      _exercises = decodedData.map((item) => Exercise.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> saveExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode({'exercise': _exercises},
        toEncodable: (Object? value) => value is Exercise
            ? Exercise.toJson(value)
            : throw UnsupportedError('Cannot convert to JSON:$value'));
    // final encodedData = jsonEncode(_exercises);
    await prefs.setString('exercises', encodedData);
  }

  void addExercise(Exercise exercise) {
    _exercises.add(exercise);
    notifyListeners();
    saveExercises();
  }

  void removeExercise(Exercise exercise) {
    _exercises.remove(exercise);
    notifyListeners();
    saveExercises();
  }

  Future<void> updateExercise(int index, Exercise updatedExercise) async {
    if (index >= 0 && index < _exercises.length) {
      _exercises[index] = updatedExercise;
      notifyListeners();
      await saveExercises();
    } else {
      print('Error: Index out of bounds for exercise update');
    }
  }
}

class ExerciseScreen extends StatefulWidget {
  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  void initState() {
    // TODO: implement initState
    ExerciseModel().loadExercises();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('운동 목록')),
      body: ChangeNotifierProvider(
        create: (context) => ExerciseModel(),
        child: Consumer<ExerciseModel>(
          builder: (context, exerciseModel, child) {
            return Column(
              children: [
                TextField(
                  onChanged: (value) {
                    // 검색 기능 구현 (생략)
                  },
                  decoration: InputDecoration(hintText: '운동 검색'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: exerciseModel.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exerciseModel.exercises[index];
                      return Dismissible(
                          key: Key(exercise.event),
                          onDismissed: (direction) {
                            exerciseModel.removeExercise(exercise);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${exercise.event} 삭제됨')),
                            );
                          },
                          child: ListTile(
                            title: Text('${exercise.part}: ${exercise.event}'),
                            trailing: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditExerciseScreen(
                                        exercise: exercise,
                                        index: index,
                                      ),
                                    ),
                                  );
                                }),
                          ));
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExerciseScreen(part: 'chest'),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// ... (AddExerciseScreen 코드는 이전과 동일)
class AddExerciseScreen extends StatefulWidget {
  final String part;

  const AddExerciseScreen({Key? key, required this.part}) : super(key: key);

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _eventController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('운동 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('파트: ${widget.part}'),
            TextField(
              controller: _eventController,
              decoration: InputDecoration(hintText: '운동 종류 입력'),
            ),
            ElevatedButton(
              onPressed: () {
                final newExercise =
                    Exercise(part: widget.part, event: _eventController.text);
                Provider.of<ExerciseModel>(context, listen: false)
                    .addExercise(newExercise);
                Navigator.pop(context);
              },
              child: Text('추가'),
            ),
          ],
        ),
      ),
    );
  }
}
