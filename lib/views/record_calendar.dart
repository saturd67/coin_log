import 'package:coin_log/main.dart';
import 'package:coin_log/views/record_details.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/shared_widgets/themedShowMonthPicker.dart';
import 'package:coin_log/constants/MonthMap.dart';
import 'package:coin_log/models/Record.dart';
import 'package:coin_log/services/RecordService.dart';

import '../router/RouterUtils.dart';

class RecordCalendar extends StatefulWidget {
  DateTime selectedDateTime;

  RecordCalendar({
    super.key,
    required this.selectedDateTime
  });

  @override
  State<RecordCalendar> createState() => _RecordCalendarState();
}

class _RecordCalendarState extends State<RecordCalendar> {
  RecordService _recordService = RecordService();

  List<List<DateTime?>> datesInMonth = [];
  Map<int, GroupedRecordItem> groupedRecordItemsWithDay = {};

  List<List<DateTime?>> getDateListByYearMonth(int year, int month) {
    List<List<DateTime?>> datesInMonth = [];
    List<DateTime?> datesInWeek = [];

    int lastDay = DateTime(year, month + 1, 0).day;
    for (int day = 1; day <= lastDay; day++) {
      DateTime dateTime = DateTime(year, month, day);

      // Add null to the day before weekday
      if (day == 1) {
        for (int i = 0; i < dateTime.weekday - 1; i++) {
          datesInWeek.add(null);
        }
      }

      if (dateTime.weekday == 1) {
        datesInMonth.add(datesInWeek);
        datesInWeek = [];
        datesInWeek.add(dateTime);
      }

      else {
        datesInWeek.add(dateTime);
      }

      if (dateTime.day == lastDay) {
        // Add null to the day after last weekday
        for (int i = 0; i < (7 - dateTime.weekday); i++) {
          datesInWeek.add(null);
        }
        datesInMonth.add(datesInWeek);
      }
    }

    return datesInMonth;
  }

  void load() async {
    final List<Record> records = await _recordService.listByYearMonth(widget.selectedDateTime.year.toString(), widget.selectedDateTime.month.toString());
    Map<int, GroupedRecordItem> groupedRecordItemsWithDay = {};
    double sumIncome = 0;
    double sumExpense = 0;
    for(Record record in records) {
      if ([RecordType.income.name, RecordType.expense.name].contains(record.type)) {
        if (!groupedRecordItemsWithDay.keys.contains(record.date.day)) {
          sumIncome = record.type == RecordType.income.name ? record.amount : 0;
          sumExpense = record.type == RecordType.expense.name ? record.amount : 0;
          groupedRecordItemsWithDay.putIfAbsent(record.date.day, () => GroupedRecordItem(sumIncome, sumExpense, [record]));
        }

        else {
          groupedRecordItemsWithDay[record.date.day]!.sumIncome += record.type == RecordType.income.name ? record.amount : 0;
          groupedRecordItemsWithDay[record.date.day]!.sumExpense += record.type == RecordType.expense.name ? record.amount : 0;
          groupedRecordItemsWithDay[record.date.day]!.records.add(record);
        }
      }
    }

    setState(() {
      this.groupedRecordItemsWithDay = groupedRecordItemsWithDay;
    });
  }

  @override
  void initState() {
    super.initState();
    datesInMonth = getDateListByYearMonth(widget.selectedDateTime.year, widget.selectedDateTime.month);
    load();
  }

  @override
  Widget build(BuildContext context) {
    final double columnWidth = (MediaQuery.sizeOf(context).width - 50) / 7;
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            shadowColor: Theme.of(context).colorScheme.surface,
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text("Calendar"),
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop("reload");
                },
                icon: Icon(Icons.arrow_back)
            ),
          ),
          body: Container(
            color: Theme.of(context).colorScheme.secondary,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                GestureDetector(
                  onTap: () async {
                    DateTime? selectedDate = await themedShowMonthPicker(context, widget.selectedDateTime);

                    if (selectedDate != null) {
                      List<List<DateTime?>> tempDateInMonth = getDateListByYearMonth(selectedDate.year, selectedDate.month);

                      setState(() {
                        widget.selectedDateTime = selectedDate;
                        datesInMonth = tempDateInMonth;
                      });
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.selectedDateTime.year.toString(),
                        style: TextStyle(
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                            fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        monthMap[widget.selectedDateTime.month.toString()]!,
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                            fontWeight: FontWeight.w500,
                        ),
                      )
                    ]
                  ),
                ),
                RecordCalendarHeader(columnWidth: columnWidth,),
                RecordCalendarBody(columnWidth: columnWidth, datesInMonth: datesInMonth, groupedRecordItemsWithDay: groupedRecordItemsWithDay, load: load)
              ],
            ),
          ),
        )
    );
  }
}

class RecordCalendarHeader extends StatelessWidget {

  final List<String> weeks = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  final double columnWidth;

  RecordCalendarHeader({
    super.key,
    required this.columnWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (String week in weeks) ... {
            Container(
                width: columnWidth,
                alignment: Alignment.center,
                child: Text(week, style: Theme.of(context).textTheme.displayMedium)
            ),
          }
        ],
      ),
    );
  }
}

class RecordCalendarBody extends StatefulWidget {
  final double columnWidth;
  final Function() load;
  List<List<DateTime?>> datesInMonth;
  Map<int, GroupedRecordItem> groupedRecordItemsWithDay;

  RecordCalendarBody({
    super.key,
    required this.columnWidth,
    required this.datesInMonth,
    required this.groupedRecordItemsWithDay,
    required this.load
  });

  @override
  State<RecordCalendarBody> createState() => _RecordCalendarBodyState();
}

class _RecordCalendarBodyState extends State<RecordCalendarBody> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Column(
        children: [
          for (List<DateTime?> datesInWeek in widget.datesInMonth) ... {
            Padding (
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (DateTime? date in datesInWeek) ... {
                    RecordCalendarBodyCell(width: widget.columnWidth, date: date, load: widget.load, sumExpend: date == null ? null : widget.groupedRecordItemsWithDay[date.day]?.sumExpense, sumIncome: date == null ? null : widget.groupedRecordItemsWithDay[date.day]?.sumIncome)
                  }
                ],
              ),
            )
          }
        ],
      )
    );
  }
}

class RecordCalendarBodyCell extends StatelessWidget {

  final double width;
  final Function() load;
  final DateTime? date;
  final double? sumExpend;
  final double? sumIncome;

  RecordCalendarBodyCell({
    super.key,
    required this.width,
    required this.load,
    this.date,
    this.sumExpend,
    this.sumIncome,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (date != null) {
          final results = await Navigator.of(context).push(RouterUtils.createRoute(RecordDetails(defaultDateTime: date!,)));
          if (results.length > 0 && results[0] == "reload") {
            load();
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6)
        ),
        width: width,
        height: 65,
        alignment: Alignment.center,
        child: date == null ?
          null :
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date!.day.toString()),
              SizedBox(
                height: 35,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (sumExpend != null && sumExpend != 0) ... {
                      Text(
                        sumExpend!.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 9,
                          color: Theme.of(context).colorScheme.danger,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    },
                    if (sumIncome != null && sumIncome != 0) ... {
                      Text(
                        sumIncome!.toStringAsFixed(2),
                        style: TextStyle(
                            fontSize: 9,
                          color: Theme.of(context).colorScheme.success
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    }
                  ],
                ),
              )
            ],
          ),
      ),
    );
  }
}

class GroupedRecordItem {
  late double sumIncome;
  late double sumExpense;
  late List<Record> records;

  GroupedRecordItem(this.sumIncome, this.sumExpense, this.records);
}
