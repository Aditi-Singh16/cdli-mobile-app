import 'package:flutter/material.dart';
import 'package:cdli_tablet_app/routes/routes.dart';
import 'package:cdli_tablet_app/models/menu_dashboard_model.dart';

class MyApp extends StatelessWidget {
  // Root of the app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'cdli tablet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        routes: routes);
  }
}
