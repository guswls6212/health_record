// exercise_list_screen.dart
import 'package:flutter/material.dart';
import 'package:health_record/src/model/body_part.dart';
import 'package:provider/provider.dart';
import '../model/exercise.dart';

class ExerciseListScreen extends StatefulWidget {
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
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  late BodyPart _bodyPart;

  @override
  void initState() {
    super.initState();
    _bodyPart = widget.bodyPart;
  }

  void _showAddExerciseDialog(BuildContext context) {
    String newExerciseName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('운동 추가'),
          content: TextField(
            onChanged: (value) {
              newExerciseName = value;
            },
            decoration: InputDecoration(hintText: '운동 이름'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () async {
                if (newExerciseName.isNotEmpty) {
                  // SQLite에 새로운 운동 저장
                  final exerciseModel =
                      Provider.of<ExerciseModel>(context, listen: false);
                  final bodyPartModel =
                      Provider.of<BodyPartModel>(context, listen: false);

                  final bodyPart = bodyPartModel.getBodyPartByName(
                      widget.bodyPart.name); // BodyPartModel에서 bodyPart 가져오기

                  var newExercise = Exercise(
                    name: newExerciseName,
                    bodyPart: bodyPart!,
                    isDefault: false,
                    sortOrder: await exerciseModel
                        .getNextSortOrder(bodyPart.name), // sortOrder 계산
                  );
                  exerciseModel.addExercise(newExercise);

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 삭제 확인 다이얼로그 표시 함수
  void _showDeleteConfirmationDialog(
      BuildContext context, Exercise exercise, ExerciseModel exerciseModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('${exercise.name} 운동을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                // 운동 삭제
                _deleteExerciseWithSnackbar(context, exercise, exerciseModel);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 운동 삭제 및 스낵바 표시 함수
  void _deleteExerciseWithSnackbar(
      BuildContext context, Exercise exercise, ExerciseModel exerciseModel) {
    // 운동 삭제
    exerciseModel.deleteExercise(exercise.name);

    // 스낵바 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${exercise.name} 운동을 삭제했습니다.'),
        action: SnackBarAction(
          label: '실행 취소',
          onPressed: () {
            // 실행 취소 로직: 삭제된 운동 다시 추가
            exerciseModel.addExercise(exercise);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<BodyPartModel>(
          builder: (context, bodyPartModel, child) {
            final bodyPart = bodyPartModel.bodyParts
                .firstWhere((element) => element.name == _bodyPart.name);
            return Text(bodyPart.name);
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final _formKey = GlobalKey<FormState>();
              String newName = _bodyPart.name;

              await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Body Part 이름 변경'),
                  content: Form(
                    key: _formKey,
                    child: TextFormField(
                      initialValue: _bodyPart.name,
                      onChanged: (value) => newName = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이름을 입력하세요.';
                        }
                        return null;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, newName);
                        }
                      },
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );

              if (newName != null && newName.isNotEmpty) {
                await Provider.of<BodyPartModel>(context, listen: false)
                    .updateBodyPart(
                        context, widget.bodyPart, newName); // context 전달

                setState(() {
                  _bodyPart = _bodyPart.copyWith(name: newName);
                });
              }
            },
          ),
        ],
      ),
      body: Consumer<ExerciseModel>(builder: (context, exerciseModel, child) {
        final exercises = exerciseModel.getExercisesByBodyPart(_bodyPart.name);
        return ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return ListTile(
              title: Text(exercise.name),
              trailing: IconButton(
                // trailing에 IconButton 추가
                icon: Icon(Icons.delete),
                onPressed: () {
                  // 삭제 확인 다이얼로그 표시
                  _showDeleteConfirmationDialog(
                      context, exercise, exerciseModel);
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 운동 추가 다이얼로그 표시
          _showAddExerciseDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
