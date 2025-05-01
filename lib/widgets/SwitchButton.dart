import 'package:flutter/material.dart';

class SwitchButton extends StatefulWidget {
  final List<String> labels;

  SwitchButton({
    super.key,
    required this.labels
  });

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  late List<String> _labels;

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
    _focusedButton = _labels[0];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _labels.length; i++)
        GestureDetector(
          onTap: () {
            setState(() {
              _focusedButton = _labels[i];
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
        // GestureDetector(
        //   onTap: () {
        //     setState(() {
        //       focusedButton = "Expense";
        //     });
        //   },
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: getBackgroundColor(focusedButton == "Expense"),
        //       border: Border.all(
        //         color: Color(0xff000000), 
        //         width: 1.0
        //       ),
        //       borderRadius: BorderRadius.only(
        //         topLeft: Radius.circular(6),
        //         bottomLeft: Radius.circular(6)
        //       )
        //     ),
        //     child: Padding(
        //       padding: const EdgeInsets.fromLTRB(20.0, 2.0, 20.0, 2.0),
        //       child: Text(
        //         "Expense", 
        //         style: TextStyle(
        //           color: getFontColor(focusedButton == "Expense"),
        //           fontWeight: FontWeight.bold
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // GestureDetector(
        //   onTap: () {
        //     setState(() {
        //       focusedButton = "Income";
        //     });
        //   },
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: getBackgroundColor(focusedButton == "Income"),
        //       border: Border.all(
        //         color:Color(0xff000000),
        //         width: 1.0
        //       ),
        //       borderRadius: BorderRadius.only(
        //         topRight: Radius.circular(6), 
        //         bottomRight: Radius.circular(6)
        //       ),
        //     ),
        //     child: Padding(
        //       padding: const EdgeInsets.fromLTRB(20.0, 2.0, 20.0, 2.0),
        //       child: Text(
        //         "Income",
        //         style: TextStyle(
        //           color: getFontColor(focusedButton == "Income"),
        //           fontWeight: FontWeight.bold
        //         )
        //       ),
        //     )
        //   ),
        // )
      ],
    );
  }
}