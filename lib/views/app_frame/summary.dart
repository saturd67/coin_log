import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:coin_log/constants/MonthMap.dart';
import 'package:coin_log/main.dart';
import 'package:coin_log/router/RouterUtils.dart';
import 'package:coin_log/services/RecordService.dart';
import 'package:coin_log/shared_widgets/switch_button.dart';
import 'package:coin_log/shared_widgets/themedShowMonthPicker.dart';
import 'package:coin_log/shared_widgets/themedShowYearPicker.dart';
import 'package:coin_log/views/budget_balance.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:fl_chart/fl_chart.dart' hide PieChart;

import '../../models/Record.dart';
import '../base_view.dart';

class SharedSelectedTransactionType extends ValueNotifier<String> {
  SharedSelectedTransactionType(super.value);
}

class SharedSelectedSummaryType extends ValueNotifier<String> {
  SharedSelectedSummaryType(super.value);
}

class SharedSelectedDateTime extends ValueNotifier<DateTime> {
  SharedSelectedDateTime(super.value);
}

class Summary extends StatefulWidget implements BaseView {
  static const classNameValue = 'Summary';

  @override
  String get className => classNameValue;

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {

  final sharedSelectedTransactionType = SharedSelectedTransactionType(RecordType.expense.name);
  final sharedSelectedSummaryType = SharedSelectedSummaryType('Monthly');
  final sharedSelectedDateTime = SharedSelectedDateTime(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        shadowColor: Theme.of(context).colorScheme.surface,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Summary")
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.fromSTEB(15, 5, 15, 5),
        color: Theme.of(context).colorScheme.secondary,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SummaryType(sharedSelectedSummaryType: sharedSelectedSummaryType, sharedSelectedDateTime: sharedSelectedDateTime),
            Expanded(
              child: ListView(
                children: [
                  SizedBox(
                      height: 120,
                      child: BalanceSummary(sharedSelectedSummaryType: sharedSelectedSummaryType, sharedSelectedDateTime: sharedSelectedDateTime)
                  ),
                  Divider(
                    height: 5,
                  ),
                  SizedBox(
                    height: 40,
                    child: SwitchButton(
                      labels: ['Expense', 'Income'],
                      selectedValue: sharedSelectedTransactionType.value,
                      onChanged: (String value) {
                        setState(() {
                          sharedSelectedTransactionType.value = value;
                        });
                      },
                    )
                  ),
                  SizedBox(
                    height: 180,
                    child: TransactionTypeSummary(sharedSelectedTransactionType: sharedSelectedTransactionType, sharedSelectedSummaryType: sharedSelectedSummaryType, sharedSelectedDateTime: sharedSelectedDateTime),
                  ),
                  Divider(
                    height: 5,
                  ),
                  SizedBox(
                    height: 250,
                    child: PeriodSummary(sharedSelectedTransactionType: sharedSelectedTransactionType, sharedSelectedSummaryType: sharedSelectedSummaryType, sharedSelectedDateTime: sharedSelectedDateTime),
                  )
                ],
              ),
            )
          ],
        ),
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
              Material(
                color: Colors.transparent,
                child:  widget.sharedSelectedSummaryType.value == "Monthly" ?
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
                  splashColor: Colors.grey[300],
                  highlightColor: Colors.grey[300],
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
                  splashColor: Colors.grey[300],
                  highlightColor: Colors.grey[300],
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

class BalanceSummary extends StatefulWidget {
  final SharedSelectedSummaryType sharedSelectedSummaryType;
  final SharedSelectedDateTime sharedSelectedDateTime;

  BalanceSummary({
    required this.sharedSelectedSummaryType,
    required this.sharedSelectedDateTime
  });

  @override
  State<BalanceSummary> createState() => _BalanceSummaryState();
}

class _BalanceSummaryState extends State<BalanceSummary> {

  RecordService _recordService = RecordService();

  late VoidCallback listener;

  double incomeAmount = 0;
  double expenseAmount = 0;

  double numerator = 0;
  double balance = 0;

  @override
  void initState() {
    super.initState();

    load();
    listener = () {
      load();
      // Optionally force UI update
      setState(() {});
    };

    widget.sharedSelectedSummaryType.addListener(listener);
    widget.sharedSelectedDateTime.addListener(listener);
  }

  @override
  void dispose() {
    widget.sharedSelectedSummaryType.removeListener(listener);
    widget.sharedSelectedDateTime.removeListener(listener);
    super.dispose();
  }

  void load() async {
    String selectedSummaryType = widget.sharedSelectedSummaryType.value;
    String selectedYear = widget.sharedSelectedDateTime.value.year.toString();
    String? selectedMonth = selectedSummaryType == "Monthly" ? widget.sharedSelectedDateTime.value.month.toString() : null;
    final tempIncomeAmount = await _recordService.sumByTypeYearMonth(RecordType.income.name, selectedYear, selectedMonth);
    final tempExpenseAmount = await _recordService.sumByTypeYearMonth(RecordType.expense.name, selectedYear, selectedMonth);


    setState(() {
      incomeAmount = tempIncomeAmount;
      expenseAmount = tempExpenseAmount;
    });
  }

  @override
  Widget build(BuildContext context) {

    Color balanceColor = Theme.of(context).colorScheme.success;
    Color numeratorColor = Theme.of(context).colorScheme.error;
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Stack(
              alignment: AlignmentDirectional.topStart,
              children: [
                Container(height: 25, width: double.infinity, color: balanceColor),
                Container(height: 25, width: incomeAmount == 0 ? 0 :(MediaQuery.of(context).size.width * expenseAmount / incomeAmount), color: numeratorColor)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                BalanceSummaryRemark(colors: [Theme.of(context).colorScheme.error], label: "Expenses: ", balance: expenseAmount,),
                BalanceSummaryRemark(colors: [Theme.of(context).colorScheme.error, Theme.of(context).colorScheme.success], label: "Income: ", balance: incomeAmount,),
                BalanceSummaryRemark(colors: [Theme.of(context).colorScheme.success], label: "Balance: ", balance: incomeAmount - expenseAmount),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              children: [
                SizedBox(
                  height: 35,
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(RouterUtils.createRoute(
                            BudgetBalance()
                        ));
                      },
                      child: Row(
                        children: [
                          Text('View Budget'),
                          Icon(Icons.keyboard_arrow_right)
                        ],
                      )
                  ),
                ),
              ],
            )
          )
        ],
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

class TransactionTypeSummary extends StatefulWidget {
  final SharedSelectedTransactionType sharedSelectedTransactionType;
  final SharedSelectedSummaryType sharedSelectedSummaryType;
  final SharedSelectedDateTime sharedSelectedDateTime;

  TransactionTypeSummary({
    required this.sharedSelectedTransactionType,
    required this.sharedSelectedSummaryType,
    required this.sharedSelectedDateTime
  });

  @override
  State<TransactionTypeSummary> createState() => _TransactionTypeSummaryState();
}

class _TransactionTypeSummaryState extends State<TransactionTypeSummary> {

  RecordService _recordService = RecordService();

  late VoidCallback listener;

  late double total = 0;

  late Map<String, double> transactionCategoryAmountMaps = {
    "": 0
  };

  @override
  void initState() {
    super.initState();
    load();
    listener = () {
      load();
      setState(() {});
    };
    widget.sharedSelectedTransactionType.addListener(listener);
    widget.sharedSelectedSummaryType.addListener(listener);
    widget.sharedSelectedDateTime.addListener(listener);
  }

  @override
  void dispose() {
    widget.sharedSelectedTransactionType.removeListener(listener);
    widget.sharedSelectedSummaryType.removeListener(listener);
    widget.sharedSelectedDateTime.removeListener(listener);
    super.dispose();
  }

  void load() async {
    String selectedTransactionType = widget.sharedSelectedTransactionType.value;
    String selectedSummaryType = widget.sharedSelectedSummaryType.value;
    String selectedYear = widget.sharedSelectedDateTime.value.year.toString();
    String? selectedMonth = selectedSummaryType == "Monthly" ? widget.sharedSelectedDateTime.value.month.toString() : null;
    List<Map<String, dynamic>> maps = await _recordService.listTransactionCategoryTotalByTypeYearMonth(selectedTransactionType, selectedYear, selectedMonth);
    double tempTotal = 0;
    // Count Top 5 Transaction Types, the rest in Others
    Map<String, double> tempTransactionCategoryAmountMaps = {};
    for (int i = 0; i < maps.length; i++) {
      if (i < 5) {
        double tempTotal = maps[i]["TOTAL"] as double;
        tempTransactionCategoryAmountMaps.putIfAbsent(maps[i]["NAME"] + ": ${tempTotal.toStringAsFixed(2)}", () => tempTotal);
      }

      else {
        double othersTotal = 0;
        if (tempTransactionCategoryAmountMaps.containsKey("Others")) {
          othersTotal += tempTransactionCategoryAmountMaps["Others"]!;
        }
        tempTransactionCategoryAmountMaps.putIfAbsent("Others", () => (maps[i]["TOTAL"] as double) + othersTotal);

        if (i == maps.length - 1) {
          double othersTotal = tempTransactionCategoryAmountMaps["Others"]!;
          tempTransactionCategoryAmountMaps.remove("Others");
          tempTransactionCategoryAmountMaps.putIfAbsent("Others: ${othersTotal.toStringAsFixed(2)}", () => othersTotal);
        }
      }

      tempTotal += maps[i]["TOTAL"] as double;
    }

    setState(() {
      if (tempTransactionCategoryAmountMaps.keys.isEmpty) {
        transactionCategoryAmountMaps = {"No Data": 0};
      }

      else {
        transactionCategoryAmountMaps = tempTransactionCategoryAmountMaps;
      }

      total = tempTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: PieChart(
        initialAngleInDegree: -90,
        colorList: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purpleAccent],
        chartRadius: 120,
        chartType: ChartType.ring,
        chartValuesOptions: ChartValuesOptions(
            showChartValues: false
        ),
        dataMap: transactionCategoryAmountMaps,
      ),
    );
  }
}

class PeriodSummary extends StatefulWidget {
  final SharedSelectedTransactionType sharedSelectedTransactionType;
  final SharedSelectedDateTime sharedSelectedDateTime;
  final SharedSelectedSummaryType sharedSelectedSummaryType;

  PeriodSummary({
    required this.sharedSelectedTransactionType,
    required this.sharedSelectedDateTime,
    required this.sharedSelectedSummaryType
  });

  @override
  State<PeriodSummary> createState() => _PeriodSummaryState();
}

class _PeriodSummaryState extends State<PeriodSummary> {

  RecordService _recordService = RecordService();

  late VoidCallback listener;

  List<Map<String, dynamic>> periodExpenseAmountMaps = [];
  List<Map<String, dynamic>> periodIncomeAmountMaps = [];
  List<Map<String, dynamic>> periodBalanceAmountMaps = [];
  double maxAmount = 0;
  double bottomTitlesInterval = 1;

  @override
  void initState() {
    super.initState();

    load();

    listener = () {
      load();
      setState(() {});
    };

    widget.sharedSelectedDateTime.addListener(listener);
    widget.sharedSelectedSummaryType.addListener(listener);
  }

  @override
  void dispose() {
    widget.sharedSelectedDateTime.removeListener(listener);
    widget.sharedSelectedSummaryType.removeListener(listener);
    super.dispose();
  }

  void load() async {
    String selectedSummaryType = widget.sharedSelectedSummaryType.value;
    String selectedYear = widget.sharedSelectedDateTime.value.year.toString();
    String selectedMonth = widget.sharedSelectedDateTime.value.month.toString().padLeft(0, "2");

    List<Map<String, dynamic>> tempPeriodIncomeAmountMaps = [];
    List<Map<String, dynamic>> tempPeriodExpenseAmountMaps = [];
    List<Map<String, dynamic>> tempPeriodBalanceAmountMaps = [];
    if  (selectedSummaryType == 'Monthly') {
      tempPeriodIncomeAmountMaps = await _recordService.listDailyTransactionCategoryTotalByYearMonthTransactionType(RecordType.income.name, selectedYear, selectedMonth);
      tempPeriodExpenseAmountMaps = await _recordService.listDailyTransactionCategoryTotalByYearMonthTransactionType(RecordType.expense.name, selectedYear, selectedMonth);
    }

    else {
      tempPeriodIncomeAmountMaps = await _recordService.listMonthlyTransactionCategoryTotalByYearMonthTransactionType(RecordType.income.name, selectedYear);
      tempPeriodExpenseAmountMaps = await _recordService.listMonthlyTransactionCategoryTotalByYearMonthTransactionType(RecordType.expense.name, selectedYear);
    }

    double cumulativeSum = 0;
    for (int i=0; i < tempPeriodIncomeAmountMaps.length; i++) {
      dynamic xDate = tempPeriodIncomeAmountMaps[i]['x_date'];

      cumulativeSum += tempPeriodIncomeAmountMaps[i]['total'];
      cumulativeSum = cumulativeSum - tempPeriodExpenseAmountMaps[i]['total'];

      Map<String, dynamic> tempPeriodBalanceAmountMap = {"x_date": xDate, "total": cumulativeSum};
      tempPeriodBalanceAmountMaps.add(tempPeriodBalanceAmountMap);
    }

    var tempPeriodTransactionAmountMaps = tempPeriodIncomeAmountMaps + tempPeriodExpenseAmountMaps;
    var tempMaxAmount = tempPeriodTransactionAmountMaps.reduce((a, b) => a['total'] > b['total'] ? a :b)['total'] * 1.1;

    setState(() {
      periodIncomeAmountMaps = tempPeriodIncomeAmountMaps;
      periodExpenseAmountMaps = tempPeriodExpenseAmountMaps;
      periodBalanceAmountMaps = tempPeriodBalanceAmountMaps;
      maxAmount = tempMaxAmount.toDouble();
      bottomTitlesInterval = tempPeriodIncomeAmountMaps.length > 12 ? 15 : 1;
    });
  }

  String compactWithOneDecimal(double value) {
    final raw = NumberFormat.compact().format(value);

    final regex = RegExp(r'^([\d\.]+)([A-Za-z]+)$');
    final match = regex.firstMatch(raw);

    if (match == null) {
      return raw;
    }

    final number = double.parse(match.group(1)!);
    final suffix = match.group(2);

    return '${number.toStringAsFixed(1)}$suffix';
  }

  double getLeftTitlesInterval(double maxAmount) {
    int length = maxAmount.toString().length;

    if (length <= 3) {
      return 300;
    }

    else {
      return pow(10, length).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    String firstPartTitle = (widget.sharedSelectedSummaryType.value == 'Monthly' ? 'Daily' : 'Monthly');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Row(
            children: [
              Text("$firstPartTitle Summary")
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
          height: 200,
          child: LineChart(
            LineChartData(
              minX: 1,
              maxX: periodIncomeAmountMaps.length.toDouble(),
              minY: 0,
              maxY: maxAmount,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: bottomTitlesInterval,
                    minIncluded: true,
                    maxIncluded: bottomTitlesInterval == 1,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}', style: const TextStyle(fontSize: 11));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: getLeftTitlesInterval(maxAmount),
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      return Text(compactWithOneDecimal(value), style: const TextStyle(fontSize: 11));
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // 🔴 hide top axis
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // 🔴 hide right axis
                ),
              ),

              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),

              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipPadding: EdgeInsets.all(5),
                  tooltipBorder: BorderSide(
                    color: Colors.black
                  ),
                  fitInsideHorizontally: true,
                  fitInsideVertically: false,
                  getTooltipColor: (LineBarSpot touchedSpot) {
                    return Colors.white;
                  }
                )
              ),

              lineBarsData: [
                LineChartBarData(
                  barWidth: 3,
                  color: Theme.of(context).colorScheme.error,
                  dotData: FlDotData(show: true),
                  spots: [
                    for  (Map<String, dynamic> periodExpenseAmountMap in periodExpenseAmountMaps) ... {
                      FlSpot(periodExpenseAmountMap['x_date'].toDouble(), double.parse(periodExpenseAmountMap['total'].toStringAsFixed(2))),
                    }
                  ],
                ),
                LineChartBarData(
                  barWidth: 3,
                  color: Theme.of(context).colorScheme.success,
                  dotData: FlDotData(show: true),
                  spots: [
                    for  (Map<String, dynamic> periodIncomeAmountMap in periodIncomeAmountMaps) ... {
                      FlSpot(periodIncomeAmountMap['x_date'].toDouble(), double.parse(periodIncomeAmountMap['total'].toStringAsFixed(2))),
                    }
                  ],
                ),
                LineChartBarData(
                  barWidth: 3,
                  color: Colors.blue,
                  dotData: FlDotData(show: true),
                  spots: [
                    for  (Map<String, dynamic> periodBalanceAmountMap in periodBalanceAmountMaps) ... {
                      FlSpot(periodBalanceAmountMap['x_date'].toDouble(), double.parse(periodBalanceAmountMap['total'].toStringAsFixed(2))),
                    }
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}