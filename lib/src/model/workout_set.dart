import '../database/database_helper.dart';

class WorkoutSet {
  double? weight; // 무게
  int? reps; // 횟수
  int? duration; // 시간

  WorkoutSet({
    this.weight,
    this.reps,
    this.duration,
  });

  // fromMap 메서드 추가
  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      weight: map[DatabaseHelper.columnWeight] as double?,
      reps: map[DatabaseHelper.columnReps] as int?,
      duration: map[DatabaseHelper.columnDuration] as int?,
    );
  }

  // toMap 메서드 추가
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnWeight: weight,
      DatabaseHelper.columnReps: reps,
      DatabaseHelper.columnDuration: duration,
    };
  }
}
