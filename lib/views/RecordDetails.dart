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
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0), child: Text("Expense: ", style: TextStyle(fontWeight: FontWeight.bold),)),
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
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context).colorScheme.tertiary
                                          ),
                                          child: Icon(Icons.picture_in_picture),
                                        ),
                                        Text("Item $itemNumber")
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
                                          width: 55,
                                          height: 55,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context).colorScheme.tertiary
                                          ),
                                          child: Icon(Icons.picture_in_picture),
                                        ),
                                        Text("Item $itemNumber")
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
                Expanded(
                  flex: isKeyboardVisible ? 0 : 2,
                  child: RecordDetailsKeyboard(isKeyboardVisible: isKeyboardVisible)
                ),
              ],
            ),
          )
        )
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
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextField(
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Descriptions'                
                ),
              ),
            ),
            if (!isKeyboardVisible)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RecordDetailsKeyboardButton(buttonText: "7"),
                        RecordDetailsKeyboardButton(buttonText: "8"),
                        RecordDetailsKeyboardButton(buttonText: "9"),
                        RecordDetailsKeyboardButton(buttonText: "Date: "),
                      ],
                    ),
                  ),
                   Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RecordDetailsKeyboardButton(buttonText: "4"),
                        RecordDetailsKeyboardButton(buttonText: "5"),
                        RecordDetailsKeyboardButton(buttonText: "6"),
                        RecordDetailsKeyboardButton(buttonText: "+"),
                      ],
                    ),
                  ),
                   Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RecordDetailsKeyboardButton(buttonText: "1"),
                        RecordDetailsKeyboardButton(buttonText: "2"),
                        RecordDetailsKeyboardButton(buttonText: "3"),
                        RecordDetailsKeyboardButton(buttonText: "-"),
                      ],
                    ),
                  ),
                   Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RecordDetailsKeyboardButton(buttonText: "."),
                        RecordDetailsKeyboardButton(buttonText: "0"),
                        RecordDetailsKeyboardButton(buttonText: "Del"),
                        RecordDetailsKeyboardButton(buttonText: "="),
                      ],
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

class RecordDetailsKeyboardButton extends StatelessWidget {
  String buttonText;

  RecordDetailsKeyboardButton({
    super.key,
    required this.buttonText
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print(buttonText);
      },
      child: Container(
        width: 95, 
        height: 40,
        decoration: BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: BorderRadius.circular(6)
        ),
        child: Center(
          child: Text(buttonText)
        ),
      ),
    );
  }
}
