import 'package:flutter/material.dart';

import '../base_view.dart';

class BaseStateless extends StatelessWidget implements BaseView {
  static const classNameValue = 'BaseStateless';

  @override
  String get className => classNameValue;

  @override
  Widget build(BuildContext context) {
    return Center();
  }
}