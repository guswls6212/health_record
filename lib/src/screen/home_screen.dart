import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../model/workout.dart'; // Workout 모델 import
import '../model/workout_record.dart';
import 'workout_record_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppLocalizations appLocalizations;
  final Function(Locale) setLocale;
  const HomeScreen(
      {Key? key, required this.appLocalizations, required this.setLocale})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<WorkoutRecordModel>(context, listen: false)
        .loadWorkoutRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(DateFormat(widget.appLocalizations.date,
                    widget.appLocalizations.localeName)
                .format(DateTime.now()))),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                          appLocalizations: widget.appLocalizations,
                          setLocale: (locale) {
                            widget.setLocale(locale);
                          },
                        )),
              );
            },
          ),
        ],
      ),
      body: Consumer<WorkoutRecordModel>(
        builder: (context, workoutRecordModel, child) {
          // WorkoutRecord를 날짜별로 그룹화
          final groupedWorkouts = groupBy(
              workoutRecordModel.workoutRecords, (WorkoutRecord r) => r.date);
          final workoutList = groupedWorkouts.entries
              .map((entry) => Workout(date: entry.key, records: entry.value))
              .toList();

          return ListView.builder(
            itemCount: workoutList.length,
            itemBuilder: (context, index) {
              final workout = workoutList[index];

              return Card(
                child: ExpansionTile(
                  title: Text(DateFormat('yyyy-MM-dd').format(workout.date)),
                  children: workout.records.map((record) {
                    return ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: Text(record.exercise.name),
                      subtitle: Text('${record.sets.length}세트'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutRecordDetailScreen(
                              workoutRecord: record,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
