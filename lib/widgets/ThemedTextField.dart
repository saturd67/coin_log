import 'package:flutter/material.dart';

class ThemedTextField extends StatefulWidget {
  final String? placeholder;
  final String? value;
  final void Function(String)? onChanged;

  ThemedTextField ({
    super.key,
    this.placeholder,
    this.value,
    this.onChanged
  });

  @override
  State<ThemedTextField> createState() => _ThemedTextFieldState();
}

class _ThemedTextFieldState extends State<ThemedTextField> {

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
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
        hintText: widget.placeholder,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2
          )
        )
      ),
      controller: _controller,
      onChanged: widget.onChanged
    );
  }
}