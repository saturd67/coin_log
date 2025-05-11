import 'package:flutter/material.dart';

class ThemedSwitch extends StatefulWidget {
  final bool value;
  final void Function(bool)? onChanged;

  ThemedSwitch ({
    super.key,
    required this.value,
    required this.onChanged
  });

  @override
  State<ThemedSwitch> createState() => _ThemedSwitchState();
}

class _ThemedSwitchState extends State<ThemedSwitch> {



  @override
  Widget build(BuildContext context) {
    return Switch(
        value: widget.value,
        activeTrackColor: Theme.of(context).colorScheme.primary,
        activeColor: Theme.of(context).colorScheme.onPrimary,
        onChanged: widget.onChanged
    );
  }
}