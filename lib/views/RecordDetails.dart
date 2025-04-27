import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class RecordDetails extends StatefulWidget {
  @override
  State<RecordDetails> createState() => _RecordDetailsState();
}

class _RecordDetailsState extends State<RecordDetails> {
  double targetItemsPerColumn = 4;
  double sourceItemsPerColumn = 1;

  bool isKeyboardVisible = false;
  late final KeyboardVisibilityController keyboardVisibilityController;
  late final StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();

    keyboardSubscription = KeyboardVisibilityController().onChange.listen((isVisible) {
      setState(() {
        isKeyboardVisible = isVisible;
      });
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            shadowColor: Theme.of(context).colorScheme.surface,
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text("Record Details")
          ),
          body: Container(
            color: Theme.of(context).colorScheme.secondary,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0), 
                          child: SwitchButton()
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                          child: SizedBox(
                            height: 265,
                            child: PageView.builder(
                              itemCount: 3, // Number of pages
                              itemBuilder: (context, pageIndex) {
                                return GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4, // 1 row
                                    childAspectRatio: 1.25, // Wide items
                                    mainAxisSpacing: 8, // Space between items
                                  ),
                                  itemCount: 12, // 4 items per page
                                  itemBuilder: (context, index) {
                                    int itemNumber = pageIndex * 4 + index + 1;
                                    return Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width:45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context).colorScheme.tertiary
                                          ),
                                          child: Icon(Icons.picture_in_picture),
                                        ),
                                        Text("Item $itemNumber", style: TextStyle(
                                          fontSize: 13
                                        ),)
                                      ],
                                    );
                                  },
                                  physics: NeverScrollableScrollPhysics(), // Disable GridView scrolling
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0), child: Text("From: ", style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                          child: SizedBox(
                            height: 85,
                            child: PageView.builder(
                              itemCount: 3, // Number of pages
                              itemBuilder: (context, pageIndex) {
                                return GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4, // 1 row
                                    childAspectRatio: 1.25, // Wide items
                                    mainAxisSpacing: 8, // Space between items
                                  ),
                                  itemCount: 4, // 4 items per page
                                  itemBuilder: (context, index) {
                                    int itemNumber = pageIndex * 4 + index + 1;
                                    return Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context).colorScheme.tertiary
                                          ),
                                          child: Icon(Icons.picture_in_picture),
                                        ),
                                        Text("Item $itemNumber", style: TextStyle(fontSize: 13),)
                                      ],
                                    );
                                  },
                                  physics: NeverScrollableScrollPhysics(),
                                );
                              },
                            )
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                // Expanded(
                //   flex: isKeyboardVisible ? 0 : 1,
                //   child: RecordDetailsKeyboard(isKeyboardVisible: isKeyboardVisible)
                // ),
                SizedBox(
                  height: isKeyboardVisible ? 92: 270,
                  child: RecordDetailsKeyboard(isKeyboardVisible: isKeyboardVisible)
                ),
              ],
            ),
          )
        )
      );

  }
}

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

class RecordDetailsKeyboard extends StatelessWidget {
  bool isKeyboardVisible;

  RecordDetailsKeyboard({
    super.key,
    required this.isKeyboardVisible
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.tertiary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,            
              children: [
                Text(style: Theme.of(context).textTheme.bodyLarge, "50.00"),
              ]
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 6.0),
              child: TextField(
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Descriptions'                
                ),
              ),
            ),
            if (!isKeyboardVisible)
              SizedBox(
                height: 175,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RecordDetailsKeyboardButton(buttonText: "7"),
                        RecordDetailsKeyboardButton(buttonText: "8"),
                        RecordDetailsKeyboardButton(buttonText: "9"),
                        RecordDetailsKeyboardButton(buttonText: "Date: "),
                      ],
                    ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: [
                         RecordDetailsKeyboardButton(buttonText: "4"),
                         RecordDetailsKeyboardButton(buttonText: "5"),
                         RecordDetailsKeyboardButton(buttonText: "6"),
                         RecordDetailsKeyboardButton(buttonText: "+"),
                       ],
                     ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: [
                         RecordDetailsKeyboardButton(buttonText: "1"),
                         RecordDetailsKeyboardButton(buttonText: "2"),
                         RecordDetailsKeyboardButton(buttonText: "3"),
                         RecordDetailsKeyboardButton(buttonText: "-"),
                       ],
                     ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: [
                         RecordDetailsKeyboardButton(buttonText: "."),
                         RecordDetailsKeyboardButton(buttonText: "0"),
                         RecordDetailsKeyboardButton(buttonText: "Del"),
                         RecordDetailsKeyboardButton(buttonText: "="),
                       ],
                     ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

class RecordDetailsKeyboardButton extends StatefulWidget {
  String buttonText;

  RecordDetailsKeyboardButton({
    super.key,
    required this.buttonText
  });

  @override
  State<RecordDetailsKeyboardButton> createState() => _RecordDetailsKeyboardButtonState();
}

class _RecordDetailsKeyboardButtonState extends State<RecordDetailsKeyboardButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          print(widget.buttonText);
        },
        onTapDown: (_) {
          setState(() {
            pressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            pressed = false;
          });
        },
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 100),
          opacity: pressed ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(6)
              ),
              child: Center(
                child: Text(widget.buttonText)
              ),
            ),
          ),
        ),
      ),
    );
  }
}
