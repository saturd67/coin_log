import 'package:flutter/material.dart';

class ThemedTextField extends StatefulWidget {
  final String? placeholder;
  final int? maxLenght;
  final TextEditingController? controller;

  ThemedTextField ({
    super.key,
    this.placeholder,
    this.maxLenght,
    this.controller
  });

  @override
  State<ThemedTextField> createState() => _ThemedTextFieldState();
}

class _ThemedTextFieldState extends State<ThemedTextField> {

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2
          )
        )
      ),
      controller: widget.controller,
      maxLength: widget.maxLenght,
      buildCounter: (
          BuildContext context, {
            required int currentLength,
            required bool isFocused,
            required int? maxLength,
          }) {
        return null; // Hides the counter
      }
    );
  }
}