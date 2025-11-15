import 'package:flutter/material.dart';

class BaseStateful extends StatefulWidget {
  @override
  State<BaseStateful> createState() => _BaseStatefulState();
}

class _BaseStatefulState extends State<BaseStateful> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:  AppBar(
            shadowColor: Theme.of(context).colorScheme.surface,
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text("Account Balance Details")
        ),
        body: Center()
    );
  }
}