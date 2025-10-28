import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/main.dart';
import 'package:coin_log/models/Budget.dart';
import 'package:coin_log/models/BudgetTransaction.dart';
import 'package:coin_log/services/BudgetService.dart';
import 'package:coin_log/services/BudgetTransactionService.dart';
import 'package:coin_log/services/RecordService.dart';
import 'package:coin_log/shared_widgets/themed_text_field.dart';
import 'package:coin_log/shared_widgets/themed_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/MonthMap.dart';
import '../shared_widgets/showConfirmationDialog.dart';
import '../shared_widgets/themedShowMonthPicker.dart';
import '../shared_widgets/themedShowYearPicker.dart';

class SharedSelectedPeriod extends ValueNotifier<Period> {
  SharedSelectedPeriod(super.value);
}

class SharedSelectedDateTime extends ValueNotifier<DateTime> {
  SharedSelectedDateTime(super.value);
}

class BudgetTransactionJoinRecordTotal {
  BudgetTransaction budgetTransaction;
  Map<String, dynamic> recordTotal;

  BudgetTransactionJoinRecordTotal({
    required this.budgetTransaction,
    required this.recordTotal
  });
}

class BudgetBalance extends StatefulWidget {
  @override
  State<BudgetBalance> createState() => _BudgetBalanceState();
}

class _BudgetBalanceState extends State<BudgetBalance> {
  BudgetTransactionService _budgetTransactionService =  BudgetTransactionService();
  BudgetService _budgetService = BudgetService();
  RecordService _recordService = RecordService();

  late VoidCallback listener;

  final sharedSelectedPeriod = SharedSelectedPeriod(Period.monthly);
  final sharedSelectedDateTime = SharedSelectedDateTime(DateTime.now());

  List<BudgetTransaction> budgetTransactions = [];
  List<BudgetTransactionJoinRecordTotal> budgetTransactionJoinRecordTotals = [];

  @override
  void initState() {
    super.initState();

    load();
    listener = () {
      load();

      setState(() {});
    };

    sharedSelectedPeriod.addListener(listener);
    sharedSelectedDateTime.addListener(listener);
  }

  @override
  void dispose() {
    sharedSelectedPeriod.removeListener(listener);
    sharedSelectedDateTime.removeListener(listener);

    super.dispose();
  }

  void load() async {
    List<BudgetTransaction> tempBudgetTransactions = await _budgetTransactionService.listByYearMonth(sharedSelectedDateTime.value.year, sharedSelectedPeriod.value == Period.monthly ? sharedSelectedDateTime.value.month : null);

    budgetTransactionJoinRecordTotals = [];
    for (BudgetTransaction tempBudgetTransaction in tempBudgetTransactions) {
      Map<String, dynamic> recordTotal = await _recordService.findRecordTotalByYearMonth(tempBudgetTransaction.transactionCategory!.name, sharedSelectedDateTime.value.year, sharedSelectedDateTime.value.month);
      budgetTransactionJoinRecordTotals.add(BudgetTransactionJoinRecordTotal(
        budgetTransaction: tempBudgetTransaction,
        recordTotal: recordTotal
      ));
    }

    setState(() {
      budgetTransactions = tempBudgetTransactions;
    });
  }

  void generateBudgetTransactions() async {
    List<Budget> budgets = await _budgetService.listByPeriodIsClosed(sharedSelectedPeriod.value, false);

    if (budgets.isEmpty) {
      ThemedToast.showToast("No budgets set.");
      return;
    }

    List<Future> futures = [];
    for (Budget budget in budgets) {
      BudgetTransaction budgetTransaction = BudgetTransaction(
          transactionCategoryId: budget.transactionCategoryId,
          budgetId: budget.identifier!,
          date: sharedSelectedPeriod.value == Period.monthly
              ? DateTime(sharedSelectedDateTime.value.year, sharedSelectedDateTime.value.month, 1)
              : DateTime(sharedSelectedDateTime.value.year, 1, 1),
          amount: budget.amount
      );

      futures.add(_budgetTransactionService.save(budgetTransaction));
    }
    await Future.wait(futures);

    load();
  }

  Future<void> refreshBudgetTransaction() async {
    List<Budget> budgets = await _budgetService.listByPeriodIsClosed(sharedSelectedPeriod.value, false);

    List<BudgetTransaction> newBudgetTransactions = [];
    for (Budget budget in budgets) {
      BudgetTransaction budgetTransaction = BudgetTransaction(
          transactionCategoryId: budget.transactionCategoryId,
          budgetId: budget.identifier!,
          date: sharedSelectedPeriod.value == Period.monthly
              ? DateTime(sharedSelectedDateTime.value.year,
              sharedSelectedDateTime.value.month, 1)
              : DateTime(sharedSelectedDateTime.value.year, 1, 1),
          amount: budget.amount
      );

      newBudgetTransactions.add(budgetTransaction);
    }

    await _budgetTransactionService.refresh(budgetTransactions, newBudgetTransactions);
    load();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              shadowColor: Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: const Text("Budget Transaction"),
              actions: [
                if (budgetTransactions.isNotEmpty)
                  IconButton(
                      onPressed: () {
                        showConfirmationDialog(
                            context,
                            "Refresh will override you existing data.",
                            () async {
                              await refreshBudgetTransaction();
                            },
                            () {}
                        );
                      },
                      icon: const Icon(Icons.update)
                  )
              ],
            ),
            body: Container(
              color: Theme.of(context).colorScheme.secondary,
              padding: EdgeInsetsDirectional.fromSTEB(15, 5, 15, 5),
              child: Column(
                children: [
                  SummaryType(sharedSelectedSummaryType: sharedSelectedPeriod, sharedSelectedDateTime: sharedSelectedDateTime),
                  Expanded(
                    child: budgetTransactions.isNotEmpty
                    ? ListView(
                      children: [
                        for (final budgetTransactionJoinRecordTotal in budgetTransactionJoinRecordTotals) ... {
                          BudgetTransactionItem(budgetTransactionJoinRecordTotal: budgetTransactionJoinRecordTotal, load: load)
                        }
                      ],
                    )
                    : Center(
                      child: ElevatedButton(
                          onPressed: () {
                            generateBudgetTransactions();
                          },
                          child: const Text("Generate")
                      )
                    )
                  )
                ],
              ),
            )
        )
    );
  }
}

class SummaryType extends StatefulWidget {
  SharedSelectedPeriod sharedSelectedSummaryType;
  SharedSelectedDateTime sharedSelectedDateTime;

  SummaryType({
    required this.sharedSelectedSummaryType,
    required this.sharedSelectedDateTime
  });

  @override
  State<SummaryType> createState() => _SummaryTypeState();
}

class _SummaryTypeState extends State<SummaryType> {

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  widget.sharedSelectedSummaryType.value = Period.monthly;
                });
              },
              child: Container(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                width: MediaQuery.of(context).size.width * 0.4,
                alignment: Alignment.center,
                child: Text("Monthly",
                  style: TextStyle(
                      fontWeight: widget.sharedSelectedSummaryType.value == Period.monthly ? FontWeight.bold : FontWeight.normal
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  widget.sharedSelectedSummaryType.value = Period.yearly;
                });
              },
              child: Container(
                padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
                width: MediaQuery.of(context).size.width * 0.4,
                alignment: Alignment.center,
                child: Text("Yearly",
                  style: TextStyle(
                      fontWeight: widget.sharedSelectedSummaryType.value == Period.yearly ? FontWeight.bold : FontWeight.normal
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: widget.sharedSelectedSummaryType.value == Period.monthly ?
                InkWell(
                    onTap: () async {
                      DateTime? tempDateTime = await themedShowMonthPicker(context, widget.sharedSelectedDateTime.value);
                      if (tempDateTime != null) {
                        setState(() {
                          widget.sharedSelectedDateTime.value = tempDateTime;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    splashColor: Colors.grey[300],    // ripple color
                    highlightColor: Colors.grey[300], // gray color on press
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                      child: Row(
                        children: [
                          Text("${monthMap[widget.sharedSelectedDateTime.value.month.toString()]!} ${widget.sharedSelectedDateTime.value.year}"),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                          )
                        ],
                      ),
                    )
                )
                    :
                InkWell(
                  onTap: () async {
                    int? tempYear = await themedShowYearPicker(context, widget.sharedSelectedDateTime.value);
                    if (tempYear != null) {
                      setState(() {
                        widget.sharedSelectedDateTime.value = DateTime(tempYear);
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(4),
                  splashColor: Colors.grey[300],    // ripple color
                  highlightColor: Colors.grey[300], // gray color on press
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                    child: Row(
                      children: [
                        Text("${widget.sharedSelectedDateTime.value.year}"),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        )
                      ],
                    ),
                  ),
                )
              )
            ],
          ),
        ),
      ],
    );
  }
}

class BudgetTransactionItem extends StatefulWidget {
  BudgetTransactionJoinRecordTotal budgetTransactionJoinRecordTotal;
  Function() load;

  BudgetTransactionItem({
    super.key,
    required this.budgetTransactionJoinRecordTotal,
    required this.load
  });

  @override
  State<BudgetTransactionItem> createState() => _BudgetTransactionItemState();
}

class _BudgetTransactionItemState extends State<BudgetTransactionItem> {
  BudgetTransactionService _budgetTransactionService = BudgetTransactionService();
  TextEditingController amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> showEditDialog(BuildContext context, BudgetTransaction budgetTransaction) async {
    amountController = TextEditingController(text: budgetTransaction.amount.toStringAsFixed(2));

    final result = await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: Theme.of(context).textTheme.displayLarge!.fontSize,
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: const Text("Edit"),
          content: SizedBox(
            width: 300,   // set width
            height: 100,  // set height
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 8.0),
                      child: Icon(
                          getTransactionCategoryIconData(budgetTransaction.transactionCategory!.icon),
                          size: 30.0
                      ),
                    ),
                    Text(budgetTransaction.transactionCategory!.name),
                  ],
                ),
                ThemedTextField(
                  placeholder: "Amount",
                  textInputType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  controller: amountController
                )
              ]
            )
          ),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.danger,),
                  onPressed: () async {
                    Navigator.of(context).pop(true);

                    showConfirmationDialog(
                      context,
                      "Are you sure you want to delete?",
                      () async {
                        await _budgetTransactionService.delete(budgetTransaction.identifier!);
                        widget.load();
                      },
                      () {
                      }
                    );
                  },
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text("Back")
                    ),
                    ElevatedButton(
                      child: const Text("Save"),
                      onPressed: () async {
                        budgetTransaction.amount = double.parse(amountController.text);
                        await _budgetTransactionService.update(budgetTransaction);
                        widget.load();
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        );
      },
    );

  }


  @override
  Widget build(BuildContext context) {

    BudgetTransaction budgetTransaction = widget.budgetTransactionJoinRecordTotal.budgetTransaction;
    Map<String, dynamic> recordTotal = widget.budgetTransactionJoinRecordTotal.recordTotal;

    double budgetAmount = budgetTransaction.amount;
    double expenseAmount = recordTotal['R_TOTAL'] ?? 0;

    print("Budget Amount: " + budgetAmount.toString());
    print("Expense Amount: " + budgetAmount.toString());

    Color unspentColor = Theme.of(context).colorScheme.success;
    Color numeratorColor = Theme.of(context).colorScheme.error;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                      child: Icon(
                          getTransactionCategoryIconData(budgetTransaction.transactionCategory!.icon),
                          size: 30.0
                      ),
                    ),
                    Text(budgetTransaction.transactionCategory!.name)
                  ],
                ),
                IconButton(
                    onPressed: () {
                      showEditDialog(context, budgetTransaction);
                    },
                    icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSecondary,)
                )
              ]
          ),
          Stack(
            alignment: AlignmentDirectional.topStart,
            children: [
              Container(height: 25, width: double.infinity, color: unspentColor),
              Container(height: 25, width: budgetAmount == 0 ? 0 :(MediaQuery.of(context).size.width * expenseAmount / budgetAmount), color: numeratorColor)
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                BalanceSummaryRemark(colors: [Theme.of(context).colorScheme.error], label: "Expenses: ", balance: expenseAmount,),
                BalanceSummaryRemark(colors: [Theme.of(context).colorScheme.error, Theme.of(context).colorScheme.success], label: "Budget: ", balance: budgetAmount,),
                BalanceSummaryRemark(colors: [Theme.of(context).colorScheme.success], label: "Unspent: ", balance: budgetAmount - expenseAmount),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class BalanceSummaryRemark extends StatelessWidget {

  final String label;
  final double balance;
  final List<Color>? colors;

  BalanceSummaryRemark({
    required this.label,
    required this.balance,
    this.colors
  });

  List<Color> generateColors(List<Color> colors) {
    if (colors.isEmpty) return [];

    List<Color> outputColors = [];
    for (int i = 0; i < colors.length; i++) {
      outputColors.add(colors[i]);
      outputColors.add(colors[i]);
    }
    return outputColors;
  }

  List<double> generateStops(int count) {
    if (count <= 0) return [];

    List<double> stops = [];
    double step = 1.0 / count;

    for (int i = 0; i < count; i++) {
      double start = i * step;
      double end = (i + 1) * step;
      stops.add(start);
      stops.add(end);
    }

    return stops;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
            child: Container(
              width: 15,
              height: 15,
              decoration: colors != null && colors!.isNotEmpty ? BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: generateColors(colors!),
                    stops: generateStops(colors!.length),
                  )
              ) : null,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall,),
              Text(balance.toStringAsFixed(2))
            ],
          )
        ],
      ),
    );
  }
}