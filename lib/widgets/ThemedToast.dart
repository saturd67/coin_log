import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ThemedToast {

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Color(0xff666666),
        textColor: Color(0xffffffff),
        fontSize: 16.0
    );
  }

}