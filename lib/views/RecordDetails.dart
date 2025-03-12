import 'package:flutter/material.dart';
import 'dart:math';


class RecordDetails extends StatelessWidget {
  double targetItemsPerColumn = 4;
  double sourceItemsPerColumn = 1;

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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  color: Color.fromARGB(255, 207, 207, 207)
                                ),
                                child: Icon(Icons.picture_in_picture),
                              ),
                              Text("Item ${itemNumber}")
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
                                  color: Color.fromARGB(255, 206, 206, 206)
                                ),
                                child: Icon(Icons.picture_in_picture),
                              ),
                              Text("Item ${itemNumber}")
                            ],
                          );
                        },
                        physics: NeverScrollableScrollPhysics(),
                      );
                    },
                  )
                ),
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
