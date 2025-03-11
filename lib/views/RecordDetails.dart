import 'package:flutter/material.dart';
import 'dart:math';


class RecordDetails extends StatelessWidget {
  double itemsPerColumn = 4;

  @override
  Widget build(BuildContext context) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            shadowColor: Theme.of(context).colorScheme.surface,
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text("Record Details")
          ),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  padding: EdgeInsets.all(5),
                  color: Theme.of(context).colorScheme.secondary,
                  child: GridView.builder(
                    itemCount: (itemsPerColumn * itemsPerColumn * 3).round(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisExtent:
                            MediaQuery.sizeOf(context).width / itemsPerColumn.round(),
                        crossAxisCount: itemsPerColumn.round()),
                    scrollDirection: Axis.horizontal,
                    physics: const PageScrollPhysics(),
                    itemBuilder: (context, index) {
                      debugPrint("gridView build item $index");
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 236, 236, 236)
                            ),
                            child: Icon(Icons.picture_in_picture),
                          ),
                          Text("Item")
                        ],
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.orange
                )
              ),
              Expanded(
                flex: 4,
                child: Container(
                  color: Colors.yellow
                )
              ),
            ],
          )
        )
      );

  }
}
