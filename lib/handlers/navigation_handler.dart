import 'package:flutter/material.dart';

/// Handles navigation
abstract class NavigationHandler {
  ///Pushes `destinationRoute` route onto the stack
  Future<dynamic>? pushNamed(String destinationRoute, {dynamic arg});

  ///Pushes `destinationRoute` onto stack and removes stack items until
  ///`lastRoute` is hit
  Future<dynamic>? pushNamedAndRemoveUntil(
      String destinationRoute, String lastRoute,
      {dynamic arg});

  ///Pushes `destinationRoute` onto stack with replacement
  Future<dynamic>? pushReplacementNamed(String destinationRoute, {dynamic arg});

  ///Pushes `destinationRoute` after popping current route off stack
  Future<dynamic>? popAndPushNamed(String destinationRoute, {dynamic arg});

  ///Pops current route off stack
  void goBack();

  ///Pops routes on stack until `destinationRoute` is hit
  void popUntil(String destinationRoute);

  ///Exits app
  void exitApp();

  ///Navigator Key
  late GlobalKey<NavigatorState> navigatorKey;
}
