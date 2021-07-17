import 'package:chess/handlers/navigation_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavigationHandlerImpl implements NavigationHandler {
  late GlobalKey<NavigatorState> navigatorKey;

  /// Constructs a NavigationHandler instance
  NavigationHandlerImpl({GlobalKey<NavigatorState>? navigatorKey}) {
    this.navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();
  }

  NavigatorState? get state => navigatorKey.currentState;

  @override
  void exitApp() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  void goBack() {
    if (state != null) {
      return state!.pop();
    }
  }

  @override
  Future? popAndPushNamed(String destinationRoute, {arg}) {
    if (state != null) {
      return state!.popAndPushNamed(destinationRoute, arguments: arg);
    }
  }

  @override
  void popUntil(String destinationRoute) {
    if (state != null) {
      return state!.popUntil(ModalRoute.withName(destinationRoute));
    }
  }

  @override
  Future? pushNamed(String destinationRoute, {arg}) {
    if (state != null) {
      return state!.pushNamed(destinationRoute, arguments: arg);
    }
  }

  @override
  Future? pushNamedAndRemoveUntil(String destinationRoute, String lastRoute,
      {arg}) {
    if (state != null) {
      return state!.pushNamedAndRemoveUntil(
        destinationRoute,
        ModalRoute.withName(lastRoute),
        arguments: arg,
      );
    }
  }

  @override
  Future? pushReplacementNamed(String destinationRoute, {arg}) {
    if (state != null) {
      return state!.pushReplacementNamed(destinationRoute, arguments: arg);
    }
  }
}
