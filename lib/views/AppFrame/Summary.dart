import 'package:coin_log/constants/MonthMap.dart';
import 'package:coin_log/main.dart';
import 'package:coin_log/services/RecordService.dart';
import 'package:coin_log/widgets/ThemedShowMonthPicker.dart';
import 'package:coin_log/widgets/ThemedShowYearPicker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:fl_chart/fl_chart.dart' hide PieChart;

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
                    height: 230,
                    child: TransactionTypeSummary(),
                  ),
                  Divider(
                    height: 5,
                  ),
                  SizedBox(
                    height: 250,
                    child: DailyTransactionSummary(),
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
    loadBalance();
    listener = () {

      loadBalance();
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

  void loadBalance() async {
    DateTime selectedDateTime = widget.sharedSelectedDateTime.value;
    final tempIncomeAmount = await _recordService.sumByTypeYearMonth("Income", selectedDateTime.year.toString(), selectedDateTime.month.toString().padLeft(2, "0"));
    final tempExpenseAmount = await _recordService.sumByTypeYearMonth("Expense", selectedDateTime.year.toString(), selectedDateTime.month.toString().padLeft(2, "0"));


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

class TransactionTypeSummary extends StatelessWidget {

  final dataMap = <String, double>{
    "Red": 40,
    "Green": 30,
    "Blue": 30,
  };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              children: [
                Text("Expenses")
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: PieChart(
              dataMap: dataMap,
              colorList: [Colors.red, Colors.green, Colors.blue],
              chartRadius: 150,
              chartType: ChartType.ring
            ),
          )
        ],
      ),

    );
  }
}

class DailyTransactionSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Row(
            children: [
              Text("Daily Expenses")
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
          height: 200,
          child: LineChart(
            LineChartData(
              minX: 1,
              maxX: 7, // 7 days
              minY: 0,
              maxY: 1000,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}', style: const TextStyle(fontSize: 11));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 300,
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
                    FlSpot(1, 50), // Day 1: $50
                    FlSpot(2, 30), // Day 2: $30
                    FlSpot(3, 70), // Day 3: $70
                    FlSpot(4, 20), // ...
                    FlSpot(5, 90),
                    FlSpot(6, 60),
                    FlSpot(7, 80),
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