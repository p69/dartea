import 'package:flutter/material.dart';
import 'package:dartea/dartea.dart';
import 'package:github_client/home/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DarteaMessagesBus(
      child: MaterialApp(
        showPerformanceOverlay: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: HomeWidget(),
      ),
    );
  }
}
