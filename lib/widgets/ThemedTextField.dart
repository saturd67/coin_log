import 'package:flutter/material.dart';

class ThemedTextField extends StatelessWidget {
  final String? placeholder;

  ThemedTextField ({
    super.key,
    this.placeholder
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: placeholder,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2
          )
        )                
      )
    );
  }
}