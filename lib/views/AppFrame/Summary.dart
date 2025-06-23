import 'package:coin_log/main.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:fl_chart/fl_chart.dart' hide PieChart;

class Summary extends StatelessWidget {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SummaryType(),
            SizedBox(
              height: 150,
              child: BalanceSummary()
            ),
            Divider(
              height: 5,
            ),
            SizedBox(
              height: 250,
              child: TransactionTypeSummary(),
            ),
            Divider(
              height: 5,
            ),
            SizedBox(
              height: 200,
              child: DailyTransactionSummary(),
            )
          ],
        ),
      )
    );
  }
}

class SummaryType extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: () {
            //
          },
          child: Container(
            padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
            width: MediaQuery.of(context).size.width * 0.4,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 2)
              )
            ),
            child: Text("Monthly",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
          ),
        ),
        InkWell(
          onTap: () {
            //
          },
          child: Container(
            padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
            width: MediaQuery.of(context).size.width * 0.4,
            alignment: Alignment.center,
            child: Text("Yearly",
              style: TextStyle(
                  fontWeight: FontWeight.normal
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BalanceSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            //
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Row(
              children: [
                Text("June 2025 ")
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Stack(
            alignment: AlignmentDirectional.topStart,
            children: [
              Container(height: 35, width: double.infinity, color: Theme.of(context).colorScheme.success),
              Container(height: 35, width: 150, color: Theme.of(context).colorScheme.error)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              BalanceSummaryRemark(colors: [Theme.of(context).colorScheme.error], label: "Expenses: ", balance: 2500,),
              BalanceSummaryRemark(colors: [Theme.of(context).colorScheme.error, Theme.of(context).colorScheme.success], label: "Income: ", balance: 4500,),
              BalanceSummaryRemark(label: "Balance: ", balance: 2500),
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
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Row(
              children: [
                Text("Expenses")
              ],
            ),
          ),
          PieChart(
            dataMap: dataMap,
            colorList: [Colors.red, Colors.green, Colors.blue],
            chartRadius: 150,
            chartType: ChartType.ring
          )
        ],
      ),

    );
  }
}

class DailyTransactionSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: SizedBox(
        width: 200,
        child: LineChart(
          LineChartData(
            minX: 1,
            maxX: 7, // 7 days
            minY: 0,
            maxY: 100,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 20,
                  getTitlesWidget: (value, meta) {
                    return Text('\$${value.toInt()}');
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
    );
  }

}