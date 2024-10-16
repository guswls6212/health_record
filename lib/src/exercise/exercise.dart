import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';
import './edit_part_screen.dart';

import 'package:uuid/uuid.dart';

@JsonSerializable()
class Exercise {
  final String id;
  final String part;
  final List<String> event;

  Exercise({String? id, required this.part, required this.event})
      : id = id ?? const Uuid().v4();

  Exercise copyWith({
    String? id,
    String? part,
    List<String>? event,
  }) {
    return Exercise(
      id: id ?? this.id,
      part: part ?? this.part,
      event: event ?? this.event,
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      part: json['part'] as String,
      event: (json['event'] as List<dynamic>).cast<String>(),
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

  Exercise getExerciseById(String id) {
    final exercise = _exercises.firstWhere((exercise) => exercise.id == id);
    if (exercise == null) {
      throw Exception('Exercise with ID $id not found');
    }
    return exercise;
  }

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
    _exercises.removeWhere((item) => item.id == exercise.id);
    notifyListeners();
    saveExercises();
  }

  Future<void> updateExercise(Exercise updatedExercise) async {
    final index =
        _exercises.indexWhere((item) => item.id == updatedExercise.id);
    print('index:$index');
    print(updatedExercise.toString());
    if (index != -1) {
      _exercises[index] = updatedExercise;
      notifyListeners(); // 상태 변경 알림
      saveExercises(); // 변경 사항 저장
    } else {
      print('해당하는 운동을 찾을 수 없습니다.');
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
                        key: Key(exercise.id), // Use part for parent key
                        onDismissed: (direction) {
                          exerciseModel.removeExercise(exercise);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${exercise.part} 삭제됨')),
                          );
                        },
                        child: ListTile(
                          title: Text('${exercise.part}'),
                          subtitle: exercise.event.isEmpty
                              ? null
                              : ListView.builder(
                                  physics:
                                      NeverScrollableScrollPhysics(), // Disable scrolling
                                  shrinkWrap:
                                      true, // Prevent nested list from expanding
                                  itemCount: exercise.event.length,
                                  itemBuilder: (context, eventIndex) {
                                    final event = exercise.event[eventIndex];
                                    return ListTile(
                                      title: Text(event),
                                    );
                                  },
                                ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Handle edit event functionality (implement later)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddExerciseScreen(exercise: exercise),
                                ),
                              );
                            },
                          ),
                        ),
                      );
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
              builder: (context) => AddExerciseScreen(
                exercise: null,
              ),
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
  final Exercise? exercise;

  const AddExerciseScreen({Key? key, required this.exercise}) : super(key: key);

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _partController = TextEditingController();
  final TextEditingController _eventController = TextEditingController();
  final List<String> _newEvents = [];

  @override
  void initState() {
    super.initState();
    // exercise와 index가 null이 아니면 수정 화면 초기화
    if (widget.exercise != null) {
      // ExerciseModel 에서 ID 를 이용하여 해당 Exercise 객체 불러오기
      try {
        final exercise = Provider.of<ExerciseModel>(context, listen: false)
            .getExerciseById(widget.exercise!.id);
        _partController.text = exercise.part; // 예시: exercise의 part 값으로 초기화
        _newEvents.addAll(exercise.event); // 기존 리스트에 새로운 요소 추가
        // ... 다른 필드 초기화
      } catch (e) {
        print('Error: Exercise not found');
        // 적절한 처리 (예: 사용자에게 알림, 화면 전환 등)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('운동 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _partController,
              decoration: InputDecoration(hintText: '파트 종류 입력'),
            ),
            TextField(
              controller: _eventController,
              decoration: InputDecoration(hintText: '운동 종류 입력'),
              onSubmitted: (value) {
                setState(() {
                  addEvent();
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  addEvent();
                  _eventController.clear();
                });
              },
              child: Text('운동 추가'),
            ),
            ElevatedButton(
              onPressed: () {
                final newExercise;

                if (widget.exercise != null) {
                  Exercise newExercise =
                      Provider.of<ExerciseModel>(context, listen: false)
                          .getExerciseById(widget.exercise!.id);

                  // 기존 객체의 값을 유지하면서 part와 event만 업데이트
                  newExercise = newExercise.copyWith(
                      id: newExercise.id,
                      part: _partController.text,
                      event: _newEvents);

                  Provider.of<ExerciseModel>(context, listen: false)
                      .updateExercise(newExercise);
                } else {
                  newExercise =
                      Exercise(part: _partController.text, event: _newEvents);
                  Provider.of<ExerciseModel>(context, listen: false)
                      .addExercise(newExercise);
                }
                Navigator.pop(context);
              },
              child: Text('추가 완료'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _newEvents.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_newEvents[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _newEvents.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addEvent() {
    setState(() {
      _newEvents.add(_eventController.text);
    });
    _eventController.clear();
  }
}
