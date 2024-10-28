import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../model/workout_record.dart';
import '../model/exercise.dart';
import '../model/workout_set.dart'; // WorkoutSet import 추가

class AddWorkoutRecordScreen extends StatefulWidget {
  const AddWorkoutRecordScreen({Key? key}) : super(key: key);

  @override
  _AddWorkoutRecordScreenState createState() => _AddWorkoutRecordScreenState();
}

class _AddWorkoutRecordScreenState extends State<AddWorkoutRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late Exercise _selectedExercise; // Exercise 타입으로 변경
  List<WorkoutSet> _sets = []; // WorkoutSet 리스트로 변경

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedExercise =
        Provider.of<ExerciseModel>(context, listen: false).exercises.first;
    _sets.add(WorkoutSet()); // 빈 WorkoutSet 추가
  }

  void _addSet() {
    setState(() {
      _sets.add(WorkoutSet()); // 빈 WorkoutSet 추가
    });
  }

  void _removeSet(int index) {
    setState(() {
      _sets.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final exerciseModel = Provider.of<ExerciseModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 기록 추가'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 선택
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Text(
                    '날짜 선택: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
              ),
              const SizedBox(height: 16.0),

              // 운동 선택
              DropdownButtonFormField<Exercise>(
                // Exercise 타입으로 변경
                value: _selectedExercise,
                onChanged: (Exercise? newValue) {
                  setState(() {
                    _selectedExercise = newValue!;
                  });
                },
                items: exerciseModel.exercises.map((exercise) {
                  return DropdownMenuItem<Exercise>(
                    value: exercise,
                    child: Text(exercise.name),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: '운동 선택',
                ),
              ),
              const SizedBox(height: 16.0),

              // 세트 추가
              Expanded(
                child: ListView.builder(
                  itemCount: _sets.length,
                  itemBuilder: (context, index) {
                    return _buildSetWidget(index);
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _addSet,
                child: const Text('세트 추가'),
              ),
              const SizedBox(height: 16.0),

              // 저장 버튼
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newRecord = WorkoutRecord(
                        id: const Uuid().v4(),
                        exercise:
                            _selectedExercise, // _selectedExerciseId 대신 _selectedExercise 사용
                        date: _selectedDate,
                        sets: _sets,
                      );
                      Provider.of<WorkoutRecordModel>(context, listen: false)
                          .addWorkoutRecord(newRecord);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetWidget(int index) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: _sets[index].weight?.toString() ?? '', // null 처리 추가
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '${index + 1}세트 무게 (kg)',
            ),
            onChanged: (value) {
              setState(() {
                _sets[index].weight =
                    double.tryParse(value); // double.tryParse() 사용
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '무게를 입력하세요.';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: TextFormField(
            initialValue: _sets[index].reps?.toString() ?? '', // null 처리 추가
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '${index + 1}세트 횟수',
            ),
            onChanged: (value) {
              setState(() {
                _sets[index].reps = int.tryParse(value);
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '횟수를 입력하세요.';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: TextFormField(
            initialValue: _sets[index].duration?.toString() ?? '', // null 처리 추가
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '${index + 1}세트 시간 (초)', // '1RM' 대신 '시간 (초)'로 변경
            ),
            onChanged: (value) {
              setState(() {
                _sets[index].duration = int.tryParse(value);
              });
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle),
          onPressed: () => _removeSet(index),
        ),
      ],
    );
  }
}
