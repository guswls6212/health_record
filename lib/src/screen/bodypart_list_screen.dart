// bodypart_list_screen.dart

import 'package:flutter/material.dart';
import 'package:health_record/src/database/dao/bodypart_dao.dart';
import 'package:provider/provider.dart';
import '../model/exercise.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'exercise_list_screen.dart';
import '../model/body_part.dart';
import 'add_update_exercise_screen.dart';
import '../database/database_helper.dart';

class BodyPartListScreen extends StatefulWidget {
  // BodyPartScreen -> BodyPartListScreen
  final AppLocalizations appLocalizations;
  final Function(Locale) setLocale;
  const BodyPartListScreen(
      {Key? key, required this.appLocalizations, required this.setLocale})
      : super(key: key);

  @override
  _BodyPartListScreenState createState() =>
      _BodyPartListScreenState(); // _BodyPartScreenState -> _BodyPartListScreenState
}

class _BodyPartListScreenState extends State<BodyPartListScreen> {
  // _BodyPartScreenState -> _BodyPartListScreenState
  final _formKey = GlobalKey<FormState>();
  final _bodyPartController = TextEditingController();

  @override
  void dispose() {
    _bodyPartController.dispose();
    super.dispose();
  }

  void _showAddBodyPartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('운동 부위 추가'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _bodyPartController,
              decoration: const InputDecoration(labelText: '운동 부위'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '운동 부위를 입력하세요.';
                }
                return null;
              },
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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // 데이터베이스에서 가장 큰 sort_order 값 가져오기
                  final bodyPartModel = Provider.of<BodyPartModel>(context,
                      listen: false); // BodyPartModel 가져오기
                  final lastSortOrder = await bodyPartModel.bodyPartDao
                      .getLastSortOrder(); // bodyPartDao를 통해 접근

                  final newBodyPart = BodyPart(
                    name: _bodyPartController.text,
                    sortOrder: lastSortOrder + 1,
                  );
                  bodyPartModel.addBodyPart(newBodyPart);
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

  @override
  void initState() {
    super.initState();
    Provider.of<ExerciseModel>(context, listen: false).loadExercises();
    Provider.of<BodyPartModel>(context, listen: false).loadBodyParts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BodyPartModel, ExerciseModel>(
      builder: (context, bodyPartModel, exerciseModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.appLocalizations.type),
          ),
          body: ListView.builder(
            itemCount: bodyPartModel.bodyParts.length,
            itemBuilder: (context, index) {
              final bodyPart = bodyPartModel.bodyParts[index];
              final exercises =
                  exerciseModel.getExercisesByBodyPart(bodyPart.name);

              return ListTile(
                title: Text('${bodyPart.name} (${exercises.length})'),
                subtitle: Text(exercises.map((e) => e.name).join(', ')),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseListScreen(
                        bodyPart: bodyPart,
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
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddBodyPartDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
