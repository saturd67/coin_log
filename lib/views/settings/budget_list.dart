import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/models/Budget.dart';
import 'package:coin_log/models/TransactionCategory.dart';
import 'package:coin_log/services/BudgetService.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/views/settings/budget_details.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../router/RouterUtils.dart';

class BudgetList extends StatefulWidget {

  @override
  State<BudgetList> createState() => _BudgetListState();
}

class _BudgetListState extends State<BudgetList> {
  BudgetService _budgetService = BudgetService();
  TransactionCategoryService _transactionCategoryService = TransactionCategoryService();

  List<Budget> _budgets = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final tempBudgets = await _budgetService.list();

    if (tempBudgets.isNotEmpty) {
      for (Budget budget in tempBudgets) {
        TransactionCategory? transactionCategory = await _transactionCategoryService.findById(budget.transactionCategoryId);
        if (transactionCategory != null) {
          budget.transactionCategory = transactionCategory;
        }
      }

      setState(() {
        _budgets = tempBudgets;
      });
    }
  }

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
                    final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => BudgetDetails()));
                    if (result == "reload") {
                      load();
                    }
                  },
                  icon: const Icon(Icons.add_box)
              )
            ],
          ),
          body: ListView(
            children: List.generate(_budgets.length, (index) {
              return BudgetItem(icon: getTransactionCategoryIconData(_budgets[index].transactionCategory!.icon), name: _budgets[index].transactionCategory!.name, page: BudgetDetails(identifer: _budgets[index].identifier), load: load);
            })
          )
        )
    );
  }
}

class BudgetItem extends StatelessWidget {
  IconData icon;
  String name;
  Widget page;
  void Function()? load;

  BudgetItem({
    super.key,
    required this.icon,
    required this.name,
    required this.page,
    this.load
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(RouterUtils.createRoute(page));

        if (result == "reload" && load != null) {
          load!();
        }
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
