import 'package:flutter/material.dart';
import 'package:namer_app/widgets/SwitchButton.dart';

class TransactionDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Transaction Details"),
          actions: [
            IconButton(
              onPressed: () {
                print("Save");
              }, 
              icon: const Icon(Icons.check)
            )
          ],
        ),
        body: Container(
          color: Theme.of(context).colorScheme.secondary,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(2.0, 12.0, 2.0, 6.0),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.tertiary
                        ),
                        child: Icon(Icons.picture_in_picture),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: TextField(
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Name',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2
                              )
                            )                
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10), 
                  child: SwitchButton(labels: ["Expense", "Income"])
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    children: List.generate(50, (index) {
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
                          Text("Item ${index + 1}", style: TextStyle(fontSize: 13),)
                        ],
                      );
                    }),
                  ),
                ),
              ]
            ),
          ),
        )
      )
    );
  }
}