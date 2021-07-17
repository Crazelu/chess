import 'package:chess/handlers/handlers.dart';
import 'package:chess/utils/route_generator.dart';
import 'package:chess/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  registerDependencies();
  runApp(ChessApp());
}

class ChessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 630),
      builder: () => MaterialApp(
        title: 'Chess',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorKey: locator<NavigationHandler>().navigatorKey,
        onGenerateRoute: RouteGenerator.onGenerateRoute,
      ),
    );
  }
}
