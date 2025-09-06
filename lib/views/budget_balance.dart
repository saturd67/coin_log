import 'package:coin_log/main.dart';
import 'package:flutter/material.dart';

import '../constants/MonthMap.dart';
import '../models/Budget.dart';
import '../shared_widgets/switch_button.dart';
import '../shared_widgets/themedShowMonthPicker.dart';
import '../shared_widgets/themedShowYearPicker.dart';

class SharedSelectedSummaryType extends ValueNotifier<String> {
  SharedSelectedSummaryType(super.value);
}

class SharedSelectedDateTime extends ValueNotifier<DateTime> {
  SharedSelectedDateTime(super.value);
}

class BudgetBalance extends StatelessWidget {

  final sharedSelectedSummaryType = SharedSelectedSummaryType('Monthly');
  final sharedSelectedDateTime = SharedSelectedDateTime(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              shadowColor: Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: const Text("Budget Balance")
            ),
            body: Container(
              color: Theme.of(context).colorScheme.secondary,
              padding: EdgeInsetsDirectional.fromSTEB(15, 5, 15, 5),
              child: Column(
                children: [
                  SummaryType(sharedSelectedSummaryType: sharedSelectedSummaryType, sharedSelectedDateTime: sharedSelectedDateTime),
                  Expanded(
                    child: ListView(
                      children: [
                        BudgetPeriodItem(),
                        BudgetPeriodItem(),
                        BudgetPeriodItem(),
                        BudgetPeriodItem(),
                        BudgetPeriodItem()
                      ],
                    ),
                  )
                ],
              ),
            )
        )
    );
  }
}

class SummaryType extends StatefulWidget {
  SharedSelectedSummaryType sharedSelectedSummaryType;
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
                  widget.sharedSelectedSummaryType.value = "Monthly";
                });
              },
              child: Container(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                width: MediaQuery.of(context).size.width * 0.4,
                alignment: Alignment.center,
                child: Text("Monthly",
                  style: TextStyle(
                      fontWeight: widget.sharedSelectedSummaryType.value == "Monthly" ? FontWeight.bold : FontWeight.normal
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  widget.sharedSelectedSummaryType.value = "Yearly";
                });
              },
              child: Container(
                padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
                width: MediaQuery.of(context).size.width * 0.4,
                alignment: Alignment.center,
                child: Text("Yearly",
                  style: TextStyle(
                      fontWeight: widget.sharedSelectedSummaryType.value == "Yearly" ? FontWeight.bold : FontWeight.normal
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
              widget.sharedSelectedSummaryType.value == "Monthly" ?
              InkWell(
                onTap: () async {
                  DateTime? tempDateTime = await themedShowMonthPicker(context, widget.sharedSelectedDateTime.value);
                  if (tempDateTime != null) {
                    setState(() {
                      widget.sharedSelectedDateTime.value = tempDateTime;
                    });
                  }
                },
                child: Text("${monthMap[widget.sharedSelectedDateTime.value.month.toString()]!} ${widget.sharedSelectedDateTime.value.year}"),
              )
                  : InkWell(
                onTap: () async {
                  int? tempYear = await themedShowYearPicker(context, widget.sharedSelectedDateTime.value);
                  if (tempYear != null) {
                    setState(() {
                      widget.sharedSelectedDateTime.value = DateTime(tempYear);
                    });
                  }
                },
                child: Text("${widget.sharedSelectedDateTime.value.year}"),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class BudgetPeriodItem extends StatefulWidget {

  @override
  State<BudgetPeriodItem> createState() => _BudgetPeriodItemState();
}

class _BudgetPeriodItemState extends State<BudgetPeriodItem> {

  double incomeAmount = 5000;
  double expenseAmount = 1000;

  @override
  Widget build(BuildContext context) {

    Color balanceColor = incomeAmount > expenseAmount ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.error;
    Color numeratorColor = incomeAmount > expenseAmount ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.success;

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
                          Icons.image,
                          size: 30.0
                      ),
                    ),
                    Text('Icon Data')
                  ],
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.edit, color: Colors.blue,)
                )
              ]
          ),
          Stack(
            alignment: AlignmentDirectional.topStart,
            children: [
              Container(height: 25, width: double.infinity, color: balanceColor),
              Container(height: 25, width: incomeAmount == 0 ? 0 :(MediaQuery.of(context).size.width * expenseAmount / incomeAmount), color: numeratorColor)
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                BalanceSummaryRemark(colors: [Theme.of(context).colorScheme.error], label: "Expenses: ", balance: expenseAmount,),
                BalanceSummaryRemark(colors: [Theme.of(context).colorScheme.error, Theme.of(context).colorScheme.success], label: "Income: ", balance: incomeAmount,),
                BalanceSummaryRemark(colors: [Theme.of(context).colorScheme.success], label: "Balance: ", balance: incomeAmount - expenseAmount),
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