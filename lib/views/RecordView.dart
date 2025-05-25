import 'package:flutter/material.dart';

class RecordView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            shadowColor: Theme.of(context).colorScheme.surface,
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text("Account Details"),
          ),
          body: Center(
            child: Text("testing"),
          ),
        )
    );
  }
}