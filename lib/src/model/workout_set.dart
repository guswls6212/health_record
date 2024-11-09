import '../database/database_helper.dart';

class WorkoutSet {
  int? set; // 세트 번호
  double? weight; // 무게
  int? reps; // 횟수
  int? duration; // 시간
  double? oneRM; // 1RM 추가

  WorkoutSet({
    this.set,
    this.weight,
    this.reps,
    this.duration,
    this.oneRM, // 1RM 추가
  });

  // fromMap 메서드 수정
  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      set: map[DatabaseHelper.columnSetNum] as int?,
      weight: map[DatabaseHelper.columnWeight] as double?,
      reps: map[DatabaseHelper.columnReps] as int?,
      duration: map[DatabaseHelper.columnDuration] as int?,
      oneRM: map[DatabaseHelper.columnOneRM] as double?, // oneRM 추가
    );
  }

  // toMap 메서드 수정
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnSetNum: set,
      DatabaseHelper.columnWeight: weight,
      DatabaseHelper.columnReps: reps,
      DatabaseHelper.columnDuration: duration,
      DatabaseHelper.columnOneRM: oneRM, // oneRM 추가
    };
  }
}
