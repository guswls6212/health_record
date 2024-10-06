import './model/exercise.dart'; // exercise.dart 파일 import
import 'package:flutter/material.dart';

class SetCard extends StatelessWidget {
  final int set;
  final double weight;
  final int reps;
  final double rm;

  const SetCard({
    Key? key,
    required this.set,
    required this.weight,
    required this.reps,
    required this.rm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Expanded(child: Center(child: Text('$set'))),
          Expanded(child: Center(child: Text('$weight kg'))),
          Expanded(child: Center(child: Text('$reps'))),
          Expanded(child: Center(child: Text('$rm kg'))),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          // 세트 삭제 로직 (예: Provider를 사용하여 상태 변경)
          // Provider.of<ExerciseModel>(context, listen: false).deleteSet(index);
        },
      ),
    );
  }
}

class WorkoutScreen extends StatelessWidget {
  // 운동 데이터 (예시)
  final List<Exercise> exercises = [
    Exercise(
      name: 'Lat pull down',
      sets: [
        Set(set: 1, weight: 43.0, reps: 15, rm: 59.13),
        // ...
      ],
    ),
    // ... 다른 운동 추가
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2024/10/02'),
      ),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          //TODO:여기 CARD위젯으로 바꿔보는게 좋을듯?
          return ExpansionTile(title: Text(exercise.name), children: [
            const Row(
              children: [
                Expanded(child: Center(child: Text('Set'))),
                Expanded(child: Center(child: Text('Weight'))),
                Expanded(child: Center(child: Text('Reps'))),
                Expanded(child: Center(child: Text('RM'))),
                Expanded(child: SizedBox()),
              ],
            ),
            Column(
              children: exercise.sets
                  .map<Widget>((set) => SetCard(
                        set: exercise.sets.indexOf(set) + 1,
                        weight: set.weight,
                        reps: set.reps,
                        rm: set.rm,
                      ))
                  .toList(),
            )
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 운동 추가 기능 구현
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
