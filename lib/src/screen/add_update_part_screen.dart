import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/exercise.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'exercise_list_screen.dart';
import '../model/body_part.dart';
import 'add_update_exercise_screen.dart';

class BodyPartScreen extends StatefulWidget {
  final AppLocalizations appLocalizations;
  final Function(Locale) setLocale;
  const BodyPartScreen(
      {Key? key, required this.appLocalizations, required this.setLocale})
      : super(key: key);

  @override
  _BodyPartScreenState createState() => _BodyPartScreenState();
}

class _BodyPartScreenState extends State<BodyPartScreen> {
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
                  // trailing 속성에 Row 위젯 추가
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExerciseScreen(),
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
