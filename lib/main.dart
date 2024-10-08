import 'package:flutter/material.dart';
import 'package:health_record/src/workout_screen.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/step_calendar.dart';
import 'src/workout_list.dart';
import 'src/workout_input.dart';
import 'src/workout_input2.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(CalendarCheck());
  // runApp(MyApp(settingsController: settingsController));
}

class CalendarCheck extends StatelessWidget {
  const CalendarCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Hada Accountbook!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: ExerciseSetScreen(),
      // WorkoutRecordInput()
      // WorkoutScreen()
      // WorkoutList()
      // StepCalendar()

      // BasicCalendar(),
      // ExpenseList(expenses: generateDummyExpenses())
      // TransactionApp(),
      // ExpenseInputScreen(),
      // const MyHomePage(title: 'Hada Accountbook!'),
    );

    // return MaterialApp(
    //   title: '근력 운동 앱',
    //   theme: ThemeData(
    //     primaryColor: Colors.red, // 주요 색상 (예: 버튼, AppBar 등)
    //     scaffoldBackgroundColor: Colors.black, // 배경 색상
    //     textTheme: TextTheme(
    //       bodyMedium: TextStyle(color: Colors.white), // 일반 텍스트 색상
    //     ),
    //     // ... 기타 테마 설정
    //   ),
    //   home: MyHomePage(),
    // );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('운동 기록'),
      ),
      body: ListView.builder(
        itemCount: 5, // 임의의 아이템 개수
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green, // 운동 종류 아이콘 배경색
              child: Icon(Icons.fitness_center, color: Colors.white),
            ),
            title: Text('벤치프레스'),
            subtitle: Text('3세트 x 10회'),
            trailing: Text('2023-11-23'),
            tileColor: Colors.blue[50], // 리스트 타일 배경색
          );
        },
      ),
    );
  }
}
