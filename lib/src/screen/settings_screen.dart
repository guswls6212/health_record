import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final AppLocalizations appLocalizations;
  final Function(Locale) setLocale;

  SettingsScreen({required this.appLocalizations, required this.setLocale});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppLocalizations _appLocalizations;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _appLocalizations = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appLocalizations.settings),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_appLocalizations
                .currentLanguage(_appLocalizations.localeName)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.setLocale(Locale('ko', 'KR'));
                setState(() {}); // setState 호출 추가
              },
              child: Text('한국어'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.setLocale(Locale('en', 'US'));
                setState(() {}); // setState 호출 추가
              },
              child: Text('English'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.setLocale(Locale('ja', 'JP'));
                setState(() {}); // setState 호출 추가
              },
              child: Text('日本語'),
            ),
          ],
        ),
      ),
    );
  }
}
