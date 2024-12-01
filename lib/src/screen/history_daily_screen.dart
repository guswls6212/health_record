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
            icon: const Icon(Icons.settings, color: Colors.white),
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
          if (workoutRecordModel.workoutRecords.isEmpty) {
            return Center(
              child: Text('No workout records'),
              // Text(widget.appLocalizations.noWorkoutRecords),
            );
          }

          // WorkoutRecord를 날짜별로 그룹화
          final groupedWorkouts = groupBy(
              workoutRecordModel.workoutRecords, (WorkoutRecord r) => r.date);
          final workoutList = <Workout>[];

          for (var entry in groupedWorkouts.entries) {
            // 날짜에서 년월일만 추출
            final date =
                DateTime(entry.key.year, entry.key.month, entry.key.day);

            // 같은 날짜의 Workout이 이미 있는지 확인
            final existingWorkout =
                workoutList.firstWhereOrNull((workout) => workout.date == date);

            if (existingWorkout != null) {
              // 이미 있는 Workout에 records 추가
              existingWorkout.records.addAll(entry.value);
            } else {
              // 새로운 Workout 생성
              workoutList.add(Workout(date: date, records: entry.value));
            }
          }

          // 최신 날짜부터 정렬
          workoutList.sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            itemCount: workoutList.length,
            itemBuilder: (context, index) {
              final workout = workoutList[index];

              return Card(
                child: ExpansionTile(
                  shape: Border.all(color: Colors.transparent),
                  initiallyExpanded: true,
                  trailing: const SizedBox.shrink(),
                  title: Text(DateFormat('dd').format(workout.date),
                      style: Theme.of(context).textTheme.titleLarge),
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
