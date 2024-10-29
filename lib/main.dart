import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'src/model/exercise.dart';
import 'src/screen/home_screen.dart';
import 'src/screen/step_calendar_screen.dart';
import 'src/model/workout_record.dart';
import 'src/screen/settings_screen.dart';
import 'src/screen/add_workout_record_screen.dart';
import 'src/screen/add_update_part_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'src/database/dao/exercise_dao.dart';
import 'src/database/database_helper.dart';
import './src/model/body_part.dart';
import './src/database/dao/bodypart_dao.dart';

// 앱 초기화 함수
// 앱 초기화 함수
Future<void> initializeApp() async {
  // 데이터베이스 초기화
  final databaseHelper = DatabaseHelper();
  final exerciseDao = ExerciseDao(databaseHelper); // ExerciseDao 인스턴스 생성
  await databaseHelper.database; // 데이터베이스 연결

  // _defaultBodyParts 추가
  final defaultBodyParts = [
    BodyPart(name: '가슴'),
    BodyPart(name: '등'),
    BodyPart(name: '하체'),
    BodyPart(name: '어깨'),
    BodyPart(name: '팔'),
  ];

  final bodyPartDao = BodyPartDao(databaseHelper); // BodyPartDao 인스턴스 생성

  for (var bodyPart in defaultBodyParts) {
    // bodyPart.name으로 데이터베이스에서 신체 부위를 조회합니다.
    final existingBodyPart = await bodyPartDao.getBodyPartByName(bodyPart.name);
    if (existingBodyPart == null) {
      await bodyPartDao.insertBodyPart(bodyPart);
    }
  }

  // _defaultExercises 추가
  final defaultExercises = [
    Exercise(
      id: const Uuid().v4(),
      name: '벤치프레스',
      bodyPart: BodyPart(name: '가슴'),
      isDefault: true,
    ),
    Exercise(
      id: const Uuid().v4(),
      name: '스쿼트',
      bodyPart: BodyPart(name: '하체'),
      isDefault: true,
    ),
  ];

  for (var exercise in defaultExercises) {
    // exercise.name으로 데이터베이스에서 운동을 조회합니다.
    final existingExercise = await exerciseDao.getExerciseByName(exercise.name);
    if (existingExercise == null) {
      await exerciseDao.insertExercise(exercise);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 작업을 위해 필요
  await initializeApp(); // 앱 초기화 함수 호출
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ExerciseModel()),
        ChangeNotifierProvider(create: (context) => WorkoutRecordModel()),
        ChangeNotifierProvider(create: (context) => BodyPartModel()),
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
        AppLocalizations.delegate,
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
        future: Future.delayed(Duration.zero, () => _appLocalizations),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MainScreen(
              appLocalizations: snapshot.data as AppLocalizations,
              setLocale: _setLocale,
            );
          } else {
            return const CircularProgressIndicator();
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
  late List<Widget> _widgetOptions; // _widgetOptions 리스트 선언

  @override
  void initState() {
    super.initState();
    Provider.of<ExerciseModel>(context, listen: false).loadExercises();
  }

  @override
  Widget build(BuildContext context) {
    _widgetOptions = <Widget>[
      HomeScreen(
          appLocalizations: widget.appLocalizations,
          setLocale: widget.setLocale), // AppLocalizations 전달
      StepCalendar(
          appLocalizations: widget.appLocalizations,
          setLocale: widget.setLocale), // AppLocalizations 전달
      BodyPartScreen(
          appLocalizations: widget.appLocalizations,
          setLocale: widget.setLocale),
    ];

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
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
