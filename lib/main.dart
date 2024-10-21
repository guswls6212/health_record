import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'src/exercise/exercise.dart';
import 'src/home_screen.dart';
import 'src/step_calendar.dart';
import 'src/workout_record.dart';
import 'src/settings_screen.dart';
import 'src/add_workout_record_screen.dart';
import 'src/exercise_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ExerciseModel()),
        ChangeNotifierProvider(create: (context) => WorkoutRecordModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale(Platform.localeName.split('_')[0]);
  AppLocalizations? _appLocalizations;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadLocale();
  }

  _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode =
        prefs.getString('languageCode') ?? _locale.languageCode;
    setState(() {
      _locale = Locale(languageCode);
      _appLocalizations = lookupAppLocalizations(_locale);
    });
  }

  _setLocale(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() {
      _locale = locale;
      _appLocalizations = lookupAppLocalizations(_locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate, // 추가
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', 'KR'),
        const Locale('en', 'US'),
        const Locale('ja', 'JP'),
      ],
      home: FutureBuilder(
        future: Future.delayed(Duration.zero,
            () => _appLocalizations), // _appLocalizations가 초기화될 때까지 기다립니다.
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MainScreen(
              appLocalizations: snapshot.data as AppLocalizations,
              setLocale: _setLocale,
            );
          } else {
            return CircularProgressIndicator(); // 또는 다른 로딩 표시
          }
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final AppLocalizations appLocalizations;
  final Function(Locale) setLocale;
  const MainScreen(
      {Key? key, required this.appLocalizations, required this.setLocale})
      : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    StepCalendar(),
    ExerciseScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<ExerciseModel>(context, listen: false).loadExercises();
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
                            // setState(() {});
                          },
                        )),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddWorkoutRecordScreen()),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '달력',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: '운동 종류',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
