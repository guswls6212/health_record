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
      body: ListView.builder(
        itemCount: widget.exercises.length,
        itemBuilder: (context, index) {
          final exercise = widget.exercises[index];
          return ListTile(
            title: Text(exercise.name),
          );
        },
      ),
    );
  }
}
