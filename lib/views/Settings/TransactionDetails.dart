import 'package:flutter/material.dart';

class TransactionDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Transaction Details"),
        ),
        body: Container(
          color: Theme.of(context).colorScheme.secondary,
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                children: List.generate(25, (index) {
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
            ]
          ),
        )
      )
    );
  }
}