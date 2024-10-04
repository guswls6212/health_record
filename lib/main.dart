import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/step_calendar.dart';

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
        // theme: ThemeData(
        //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        //   useMaterial3: true,
        // ),
        home: StepCalendar()

        // BasicCalendar(),
        // ExpenseList(expenses: generateDummyExpenses())
        // TransactionApp(),
        // ExpenseInputScreen(),
        // const MyHomePage(title: 'Hada Accountbook!'),
        );
  }
}
