import 'package:flutter/material.dart';

import '../views/base_view.dart';

class RouterUtils {
  static Route createRoute(Widget widget) {

    if (widget is! BaseView) {
      throw ArgumentError('Widget must implement View_');
    }

    final view_ = widget as BaseView;

    return PageRouteBuilder(
      settings: RouteSettings(name: view_.className),
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}


