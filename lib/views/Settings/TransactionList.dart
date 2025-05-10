import 'package:coin_log/objects/TransactionCategory.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/views/Settings/TransactionDetails.dart';
import 'package:coin_log/widgets/GridViewIcon.dart';
import 'package:coin_log/widgets/SwitchButton.dart';

import 'package:coin_log/constants/TransactionCategoryMap.dart';
import 'package:reorderables/reorderables.dart';

class TransactionList extends StatefulWidget {

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {

  TransactionCategoryService _transactionCategoryService = TransactionCategoryService();

  List<TransactionCategory> _transactionCategories = [];
  String _selectedType = "Expense";
  int? _reorderIndex;

  @override
  void initState() {
    super.initState();
    loadTransactionCategories();
  }

  void loadTransactionCategories() async {
    final _transactionCategories = await _transactionCategoryService.listByType(_selectedType);
    setState(() {
      this._transactionCategories = _transactionCategories;
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
                      final result = await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => TransactionDetails()));
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
                            selectedValue: _selectedType,
                            onChanged: (String value) {
                              setState(() {
                                _selectedType = value;
                                loadTransactionCategories();
                              });
                            },
                          )
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.83,
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: PrimaryScrollController(
                            controller: ScrollController(),
                            child: ReorderableWrap(
                                alignment: WrapAlignment.spaceBetween,
                                spacing: 8.0,
                                runSpacing: 8.0,
                                maxMainAxisCount: 4,
                                buildDraggableFeedback: (context, constraints, child) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GridViewIcon(iconData: coinLogIconMap[_transactionCategories[_reorderIndex!].icon]!.icon, containerSize: 55, iconSize: 26),
                                    ],
                                  );
                                },
                                onReorderStarted: (index) {
                                  setState(() {
                                    _reorderIndex = index;
                                  });
                                },
                                onReorder: (oldIndex, newIndex) async {
                                  setState(() {
                                    _reorderIndex = null;
                                    final item = _transactionCategories.removeAt(oldIndex);
                                    _transactionCategories.insert(newIndex, item);
                                  });

                                  await _transactionCategoryService.updateSequence(_transactionCategories);
                                },
                                children: List.generate(_transactionCategories.length, (index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => TransactionDetails(identifier: _transactionCategories[index].identifier)));
                                      if (result == "reload") {
                                        loadTransactionCategories();
                                      }
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        GridViewIcon(iconData: coinLogIconMap[_transactionCategories[index].icon]!.icon),
                                        Text(_transactionCategories[index].name, style: TextStyle(fontSize: 13))
                                      ],
                                    ),
                                  );
                                })
                            ),
                          )
                      ),
                    ]
                ),
              ),
            )
        )
    );
  }
}