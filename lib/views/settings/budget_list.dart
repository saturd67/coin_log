import 'package:coin_log/views/settings/budget_details.dart';
import 'package:flutter/material.dart';

import '../../router/RouterUtils.dart';

class BudgetList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            shadowColor: Theme.of(context).colorScheme.surface,
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text("Budgets"),
            actions: [
              IconButton(
                  onPressed: () async {
                    // final result = await Navigator.of(context).push(
                    //     MaterialPageRoute(builder: (context) => AccountDetails()));
                    // if (result == "reload") {
                    //   load();
                    // }
                  },
                  icon: const Icon(Icons.add_box)
              )
            ],
          ),
          body: ListView(
            children: [
              BudgetItem(icon: Icons.image, name: "Budget Item 1", page: BudgetDetails())
            ],
          )
        )
    );
  }
}

class BudgetItem extends StatelessWidget {
  IconData icon;
  String name;
  Widget page;

  BudgetItem({
    super.key,
    required this.icon,
    required this.name,
    required this.page
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(RouterUtils.createRoute(page));
      },
      child: Container(
          color: Theme.of(context).colorScheme.secondary,
          height: 65,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                    child: Icon(
                        icon,
                        size: 30.0
                    ),
                  ),
                  Text(name)
                ]
            ),
          )
      ),
    );
  }

}
