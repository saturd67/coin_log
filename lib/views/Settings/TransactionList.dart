import 'package:flutter/material.dart';
import 'package:namer_app/views/Settings/TransactionDetails.dart';
import 'package:namer_app/widgets/SwitchButton.dart';

class TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Transactions"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => TransactionDetails()));
              }, 
              icon: const Icon(Icons.add_box)
            )
          ],
        ),
        body: Container(
          color: Theme.of(context).colorScheme.secondary,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10), 
                  child: SwitchButton(labels: ["Expenses", "Income"])
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.83,
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