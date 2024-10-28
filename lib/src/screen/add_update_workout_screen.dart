// add_update_workout_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../model/exercise.dart';
import '../model/body_part.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({Key? key}) : super(key: key);

  @override
  _AddWorkoutScreenState createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedBodyPart;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseModel>(
      builder: (context, exerciseModel, child) {
        // SQLite에 저장된 bodyPart 목록 가져오기
        final bodyParts = exerciseModel.exercises
            .map((exercise) => exercise.bodyPart.name)
            .toSet()
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('운동 추가'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 운동 부위 드롭다운
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '운동 부위'),
                    value: _selectedBodyPart,
                    items:
                        bodyParts.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBodyPart = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // 운동 이름 입력 필드
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
                  const SizedBox(height: 16.0),
                  // 메모 내용 입력 필드 - 필요하다면 추가
                  // TextFormField(
                  //   decoration: const InputDecoration(labelText: '메모 내용'),
                  //   maxLines: 5,
                  // ),
                  const Spacer(),
                  // 저장 버튼
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // 유효성 검사 통과 시
                        final newExercise = Exercise(
                          id: const Uuid().v4(),
                          name: _nameController.text,
                          bodyPart: BodyPart(name: _selectedBodyPart!),
                        );
                        exerciseModel.addExercise(newExercise);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
