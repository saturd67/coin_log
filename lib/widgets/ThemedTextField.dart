import 'package:flutter/material.dart';

class ThemedTextField extends StatefulWidget {
  final String? placeholder;
  final int? maxLenght;
  final String? value;
  final void Function(String)? onChanged;

  ThemedTextField ({
    super.key,
    this.placeholder,
    this.maxLenght,
    this.value,
    this.onChanged
  });

  @override
  State<ThemedTextField> createState() => _ThemedTextFieldState();
}

class _ThemedTextFieldState extends State<ThemedTextField> {
  late String? _placeholder;
  late int? _maxLength;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _placeholder = widget.placeholder;
    _maxLength = widget.maxLenght;

    setState(() {
      _controller.text = widget.value ?? "";
    });
  }

  @override
  void didUpdateWidget(covariant ThemedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != _controller.text) {
      _controller.text = widget.value!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: _placeholder,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2
          )
        )
      ),
      controller: _controller,
      maxLength: _maxLength,
      onChanged: widget.onChanged
    );
  }
}