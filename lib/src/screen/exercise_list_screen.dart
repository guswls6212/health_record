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

  // 운동 수정 다이얼로그 표시 함수
  void _showEditExerciseDialog(
      BuildContext context, Exercise exercise, ExerciseModel exerciseModel) {
    String editedExerciseName = exercise.name;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('운동 수정'),
          content: TextField(
            onChanged: (value) {
              editedExerciseName = value;
            },
            controller: TextEditingController(text: exercise.name),
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
              onPressed: () {
                if (editedExerciseName.isNotEmpty) {
                  // 운동 수정 및 스낵바 표시
                  _editExerciseWithSnackbar(
                      context, exercise, exerciseModel, editedExerciseName);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 운동 수정 및 스낵바 표시 함수
  void _editExerciseWithSnackbar(BuildContext context, Exercise exercise,
      ExerciseModel exerciseModel, String newName) {
    // 운동 수정
    var editedExercise = exercise.copyWith(name: newName);
    exerciseModel.editExercise(exercise, editedExercise);

    // 스낵바 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${exercise.name} 운동을 ${newName}으로 변경했습니다.'),
        action: SnackBarAction(
          label: '실행 취소',
          onPressed: () {
            // 실행 취소 로직: 원래 운동 이름으로 되돌리기
            exerciseModel.editExercise(editedExercise, exercise);
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
      ),
      body: Consumer<ExerciseModel>(builder: (context, exerciseModel, child) {
        final exercises = exerciseModel.getExercisesByBodyPart(_bodyPart.name);
        return ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return ListTile(
              title: Text(exercise.name),
              trailing: Wrap(
                spacing: 8.0,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit), // 연필 아이콘 추가
                    onPressed: () {
                      // 운동 수정 다이얼로그 표시
                      _showEditExerciseDialog(context, exercise, exerciseModel);
                    },
                  ),
                  IconButton(
                    // trailing에 IconButton 추가
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // 삭제 확인 다이얼로그 표시
                      _showDeleteConfirmationDialog(
                          context, exercise, exerciseModel);
                    },
                  ),
                ],
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
