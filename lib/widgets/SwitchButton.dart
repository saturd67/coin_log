import 'package:flutter/material.dart';

class SwitchButton extends StatefulWidget {
  const SwitchButton({
    super.key,
  });

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  String focusedButton = "Expense";

  Color getBackgroundColor(bool isFocus) {
    return isFocus ? Color(0xff000000) : Color(0xffffffff);
  }

  Color getFontColor(bool isFocus) {
    return isFocus ? Color(0xffffffff) : Color(0xff000000);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              focusedButton = "Expense";
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: getBackgroundColor(focusedButton == "Expense"),
              border: Border.all(
                color: Color(0xff000000), 
                width: 1.0
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6)
              )
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 2.0, 20.0, 2.0),
              child: Text(
                "Expense", 
                style: TextStyle(
                  color: getFontColor(focusedButton == "Expense"),
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              focusedButton = "Income";
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: getBackgroundColor(focusedButton == "Income"),
              border: Border.all(
                color:Color(0xff000000),
                width: 1.0
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(6), 
                bottomRight: Radius.circular(6)
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 2.0, 20.0, 2.0),
              child: Text(
                "Income",
                style: TextStyle(
                  color: getFontColor(focusedButton == "Income"),
                  fontWeight: FontWeight.bold
                )
              ),
            )
          ),
        )
      ],
    );
  }
}