import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/exercise.dart';
import '../model/body_part.dart'; // BodyPart import
import 'package:uuid/uuid.dart';

class AddExerciseScreen extends StatefulWidget {
  // 클래스 이름 변경
  const AddExerciseScreen({Key? key}) : super(key: key);

  @override
  _AddExerciseScreenState createState() =>
      _AddExerciseScreenState(); // State 클래스 이름 변경
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  // State 클래스 이름 변경
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedBodyPart; // 선택된 BodyPart 이름을 저장할 변수

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
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
              Consumer<BodyPartModel>(
                // BodyPartModel에서 bodyParts 가져오기
                builder: (context, bodyPartModel, child) {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '신체 부위'),
                    value: _selectedBodyPart,
                    items: bodyPartModel.bodyParts.map((bodyPart) {
                      return DropdownMenuItem(
                        value: bodyPart.name,
                        child: Text(bodyPart.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBodyPart = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '신체 부위를 선택하세요.';
                      }
                      return null;
                    },
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // 유효성 검사 통과 시
                    final newExercise = Exercise(
                      name: _nameController.text,
                      bodyPart:
                          BodyPart(name: _selectedBodyPart!), // BodyPart 객체 생성
                    );
                    Provider.of<ExerciseModel>(context, listen: false)
                        .addExercise(newExercise);
                    Navigator.pop(context);
                  }
                },
                child: const Text('추가'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
