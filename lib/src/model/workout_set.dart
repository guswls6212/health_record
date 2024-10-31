import '../database/database_helper.dart';

class WorkoutSet {
  int? set; // 세트 번호 추가
  double? weight; // 무게
  int? reps; // 횟수
  int? duration; // 시간

  WorkoutSet({
    this.set, // 세트 번호 추가
    this.weight,
    this.reps,
    this.duration,
  });

  // fromMap 메서드 수정
  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      set: map[DatabaseHelper.columnSetNum] as int?, // set_num 추가
      weight: map[DatabaseHelper.columnWeight] as double?,
      reps: map[DatabaseHelper.columnReps] as int?,
      duration: map[DatabaseHelper.columnDuration] as int?,
    );
  }

  // toMap 메서드 수정
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnSetNum: set, // set_num 추가
      DatabaseHelper.columnWeight: weight,
      DatabaseHelper.columnReps: reps,
      DatabaseHelper.columnDuration: duration,
    };
  }
}
