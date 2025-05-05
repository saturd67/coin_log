import 'package:flutter/material.dart';

class SwitchButton extends StatefulWidget {
  final List<String> labels;
  final String selectedValue;
  final void Function(String)? onChanged;

  SwitchButton({
    super.key,
    required this.labels,
    required this.selectedValue,
    this.onChanged
  });

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  late List<String> _labels;
  late void Function(String)? _onChanged;

  late String _focusedButton = "";

  Color getBackgroundColor(bool isFocus) {
    return isFocus ? Color(0xff000000) : Color(0xffffffff);
  }

  Color getFontColor(bool isFocus) {
    return isFocus ? Color(0xffffffff) : Color(0xff000000);
  }

  @override
  void initState() {
    super.initState();
    _labels = widget.labels;
    _focusedButton = widget.selectedValue ?? _labels[0];
    _onChanged = widget.onChanged;
  }

  @override
  void didUpdateWidget(covariant SwitchButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedValue != _focusedButton) {
      setState(() {
        _focusedButton = widget.selectedValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _labels.length; i++) ... {
          GestureDetector(
            onTap: () {
              setState(() {
                _focusedButton = _labels[i];

                if (_onChanged != null) {
                  _onChanged!(_focusedButton);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: getBackgroundColor(_focusedButton == _labels[i]),
                border: Border.all(
                  color: Color(0xff000000), 
                  width: 1.0
                ),
                borderRadius: i == 0
                ? BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6)
                )
                : i == _labels.length - 1
                ? BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6)
                )
                : BorderRadius.circular(0)
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 2.0, 20.0, 2.0),
                child: Text(
                  _labels[i], 
                  style: TextStyle(
                    color: getFontColor(_focusedButton == _labels[i]),
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ), 
        }
      ],
    );
  }
}