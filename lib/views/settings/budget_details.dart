import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BudgetDetails extends StatefulWidget {

  int? identiifer;

  BudgetDetails({
    this.identiifer
  });

  @override
  State<BudgetDetails> createState() => _BudgetDetailsState();
}

class _BudgetDetailsState extends State<BudgetDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              shadowColor: Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: const Text("Budget Details"),
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