import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkoutList extends StatefulWidget {
  @override
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  final List<Map<String, dynamic>> workouts = [
    {
      'title': 'Chest',
      'date': DateTime.now().subtract(Duration(days: 1, hours: 11)),
      'exercises': ['라테라ルフ라이', 'smith machine bench press', 'chest press'],
    },
    // ... 다른 운동 데이터 추가
  ];

  final TextEditingController _exerciseController = TextEditingController();

  String formatDate(DateTime dateTime) {
    return DateFormat('yMd').format(dateTime);
  }

  void _showAddExerciseDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('운동 추가'),
          content: TextField(
            controller: _exerciseController,
            decoration: InputDecoration(hintText: '운동 이름'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  workouts[index]['exercises'].add(_exerciseController.text);
                });
                _exerciseController.clear();
                Navigator.pop(context);
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('운동 기록'),
      ),
      body: ListView.builder(
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ExpansionTile(
              title:
                  Text('${workout['title']} - ${formatDate(workout['date'])}'),
              children: workout['exercises']
                  .map<Widget>((exercise) => ListTile(
                        leading: Icon(Icons.fitness_center),
                        title: Text(exercise),
                        subtitle: Text('3세트 x 10회'),
                      ))
                  .toList(),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _showAddExerciseDialog(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      // 더 보기 기능 구현 (예: 운동 수정, 삭제)
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // ... 다른 메뉴 추가
        ],
      ),
    );
  }
}
