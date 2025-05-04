import 'package:coin_log/objects/TransactionCategory.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/views/Settings/TransactionDetails.dart';
import 'package:coin_log/widgets/GridViewIcon.dart';
import 'package:coin_log/widgets/SwitchButton.dart';

import 'package:coin_log/constants/TransactionCategoryMap.dart';

class TransactionList extends StatefulWidget {

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {

  TransactionCategoryService transactionCategoryService = TransactionCategoryService();

  List<TransactionCategory> transactionCategories = [];
  String selectedType = "Expense";

  @override
  void initState() {
    super.initState();
    loadTransactionCategories();
  }

  void loadTransactionCategories() async {
    final transactionCategories = await transactionCategoryService.listByType(selectedType);
    setState(() {
      this.transactionCategories = transactionCategories;
    });
  }

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
              onPressed: () async {
                final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => TransactionDetails()));

                if (result == "reload") {
                  loadTransactionCategories();
                }
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
                  child: SwitchButton(
                    labels: ["Expense", "Income"],
                    selectedValue: selectedType,
                    onChanged: (String value) {
                      setState(() {
                        selectedType = value;
                        loadTransactionCategories();
                      });
                    },
                  )
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.83,
                  child: GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    children: List.generate(transactionCategories.length, (index) {
                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => TransactionDetails(identifier: transactionCategories[index].identifier)));

                          if (result == "reload") {
                            loadTransactionCategories();
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GridViewIcon(iconData: coinLogIconMap[transactionCategories[index].icon]!.icon),
                            Text(transactionCategories[index].name, style: TextStyle(fontSize: 13),)
                          ],
                        ),
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