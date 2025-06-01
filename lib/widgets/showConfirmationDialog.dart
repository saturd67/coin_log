import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> showConfirmationDialog(BuildContext context, String message, Function() onYes, Function() onNo) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        titleTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize:  Theme.of(context).textTheme.displayLarge!.fontSize),
        title: Text('Confirm'),
        content: Text(message),
        actions: <Widget> [
          TextButton(
            onPressed: () => {Navigator.of(context).pop(false)},
            child: Text('No'),
          ),
          TextButton(
              onPressed: () => {Navigator.of(context).pop(true)},
              child: Text('Yes')
          )
        ],
      );
    }
  );

  if (result == true) {
    await onYes();
  }

  else {
    await onNo();
  }
}