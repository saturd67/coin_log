import 'package:coin_log/constants/MonthMap.dart';
import 'package:coin_log/main.dart';
import 'package:coin_log/services/RecordService.dart';
import 'package:coin_log/widgets/switch_button.dart';
import 'package:coin_log/widgets/themedShowMonthPicker.dart';
import 'package:coin_log/widgets/themedShowYearPicker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:fl_chart/fl_chart.dart' hide PieChart;

class SharedSelectedTransactionType extends ValueNotifier<String> {
  SharedSelectedTransactionType(String value) : super(value);
}

class SharedSelectedSummaryType extends ValueNotifier<String> {
  SharedSelectedSummaryType(String value) : super(value);
}

class SharedSelectedDateTime extends ValueNotifier<DateTime> {
  SharedSelectedDateTime(DateTime value) : super(value);
}

class Summary extends StatefulWidget {
  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {

  final sharedSelectedTransactionType = SharedSelectedTransactionType('Expense');
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
                      height: 100,
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
    final tempIncomeAmount = await _recordService.sumByTypeYearMonth("Income", selectedYear, selectedMonth);
    final tempExpenseAmount = await _recordService.sumByTypeYearMonth("Expense", selectedYear, selectedMonth);


    setState(() {
      incomeAmount = tempIncomeAmount;
      expenseAmount = tempExpenseAmount;
    });
  }
  
  @override
  Widget build(BuildContext context) {

    Color balanceColor = incomeAmount > expenseAmount ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.error;
    Color numeratorColor = incomeAmount > expenseAmount ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.success;
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
            children: [
              Text(label),
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
    List<Map<String, dynamic>> maps = await _recordService.listTransactionCategoryAmountByTypeYearMonth(selectedTransactionType, selectedYear, selectedMonth);
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
        transactionCategoryAmountMaps = {"No Date": 0};
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

  List<Map<String, dynamic>> periodTransactionAmountMaps = [];
  double maxAmount = 0;
  double leftTitlesInterval = 300;
  double bottomTitlesInterval = 1;

  @override
  void initState() {
    super.initState();

    load();

    listener = () {
      load();
      setState(() {});
    };

    widget.sharedSelectedTransactionType.addListener(listener);
    widget.sharedSelectedDateTime.addListener(listener);
    widget.sharedSelectedSummaryType.addListener(listener);
  }

  @override
  void dispose() {
    widget.sharedSelectedTransactionType.removeListener(listener);
    widget.sharedSelectedDateTime.removeListener(listener);
    widget.sharedSelectedSummaryType.removeListener(listener);
    super.dispose();
  }

  void load() async {
    String selectedTransactionType = widget.sharedSelectedTransactionType.value;
    String selectedSummaryType = widget.sharedSelectedSummaryType.value;
    String selectedYear = widget.sharedSelectedDateTime.value.year.toString();
    String selectedMonth = widget.sharedSelectedDateTime.value.month.toString().padLeft(0, "2");

    List<Map<String, dynamic>> tempPeriodTransactionAmountMaps = [];
    if  (selectedSummaryType == 'Monthly') {
      tempPeriodTransactionAmountMaps = await _recordService.listDailyTransactionCategoryAmountByYearMonthTransactionType(selectedTransactionType, selectedYear, selectedMonth);
    }

    else {
      tempPeriodTransactionAmountMaps = await _recordService.listMonthlyTransactionCategoryAmountByYearMonthTransactionType(selectedTransactionType, selectedYear);
      tempPeriodTransactionAmountMaps.forEach((map) => print(map));
    }

    setState(() {
      periodTransactionAmountMaps = tempPeriodTransactionAmountMaps;
      maxAmount = tempPeriodTransactionAmountMaps.reduce((a, b) => a['total'] > b['total'] ? a :b)['total'];
      bottomTitlesInterval = periodTransactionAmountMaps.length > 12 ? 15 : 1;
      leftTitlesInterval = maxAmount > 1000 ? 1000 : 300;
    });
  }



  @override
  Widget build(BuildContext context) {
    String firstPartTitle = (widget.sharedSelectedSummaryType.value == 'Monthly' ? 'Daily' : 'Monthly');
    String lastPartTitle = (widget.sharedSelectedTransactionType.value == 'Expense' ? 'Expenses' : 'Income');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Row(
            children: [
              Text("$firstPartTitle $lastPartTitle")
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
          height: 200,
          child: LineChart(
            LineChartData(
              minX: 1,
              maxX: periodTransactionAmountMaps.length.toDouble(), // 7 days
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
                    interval: leftTitlesInterval,
                    getTitlesWidget: (value, meta) {
                      final formattedValue = NumberFormat.compact().format(value);
                      return Text(formattedValue, style: const TextStyle(fontSize: 11));
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

              lineBarsData: [
                LineChartBarData(
                  barWidth: 3,
                  color: Colors.blue,
                  dotData: FlDotData(show: true),
                  spots: [
                    for  (Map<String, dynamic> periodTransactionAmountMap in periodTransactionAmountMaps) ... {
                      FlSpot(periodTransactionAmountMap['x_date'].toDouble(), periodTransactionAmountMap['total'].toDouble()),
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