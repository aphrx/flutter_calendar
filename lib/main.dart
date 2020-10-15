import 'package:flutter/material.dart';
import 'package:flutter_cal/calendar.dart';
import 'package:flutter_cal/db.dart';
import 'package:flutter_cal/theme.dart';
import 'package:provider/provider.dart';


void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
              create: (_) => ThemeNotifier(),
              child: Consumer<ThemeNotifier>(
                  builder: (context, ThemeNotifier notifier, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: notifier.isDarkTheme ? dark : light,
                  home: Calendar(),
                );
              }),
            );
  }
}

