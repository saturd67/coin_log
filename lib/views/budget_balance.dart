import 'package:flutter/material.dart';

class BudgetBalance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              shadowColor: Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: const Text("Budget Balance"),
              actions: [
                IconButton(
                    onPressed: () async {

                      Navigator.of(context).pop("reload");
                    },
                    icon: const Icon(Icons.check)
                )
              ],
            ),
            body: Container(
              color: Theme.of(context).colorScheme.secondary,
              child: Column(
                children: [

                ],
              ),
            )
        )
    );
  }
}