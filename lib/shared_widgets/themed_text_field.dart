import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemedTextField extends StatefulWidget {
  final String? placeholder;
  final int? maxLength;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;

  ThemedTextField ({
    super.key,
    this.placeholder,
    this.maxLength,
    this.textInputType,
    this.inputFormatters,
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
      maxLength: widget.maxLength,
      keyboardType: widget.textInputType,
      inputFormatters: widget.inputFormatters,
      controller: widget.controller,
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