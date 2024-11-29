import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:health_record/src/screen/add_workout_record_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../model/workout.dart'; // Workout 모델 import
import '../model/workout_record.dart';
import 'workout_record_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'settings_screen.dart';

class HistoryDailyScreen extends StatefulWidget {
  final AppLocalizations appLocalizations;
  final Function(Locale) setLocale;
  const HistoryDailyScreen(
      {Key? key, required this.appLocalizations, required this.setLocale})
      : super(key: key);

  @override
  State<HistoryDailyScreen> createState() => _HistoryDailyScreenState();
}

class _HistoryDailyScreenState extends State<HistoryDailyScreen> {
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
            child: Text(
          DateFormat(widget.appLocalizations.date,
                  widget.appLocalizations.localeName)
              .format(DateTime.now()),
          // style: Theme.of(context).textTheme.titleLarge,
        )),
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
                      title: Text(record.exerciseName),
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
      floatingActionButton: FloatingActionButton(
        // FloatingActionButton 추가
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddWorkoutRecordScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
