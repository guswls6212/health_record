import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Locale _locale = Locale(Platform.localeName.split('_')[0]);

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
    });
  }

  _setLocale(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(AppLocalizations.of(context)!.settings),
        title: Text('setting'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(AppLocalizations.of(context)!
            //     .currentLanguage(AppLocalizations.of(context)!.localeName)),
            Text('localeName'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _setLocale(const Locale('ko', 'KR'));
              },
              child: const Text('한국어'),
            ),
            ElevatedButton(
              onPressed: () {
                _setLocale(const Locale('en', 'US'));
              },
              child: const Text('English'),
            ),
            ElevatedButton(
              onPressed: () {
                _setLocale(const Locale('ja', 'JP'));
              },
              child: const Text('日本語'),
            ),
          ],
        ),
      ),
    );
  }
}
