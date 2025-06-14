import 'package:coin_log/main.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/widgets/ThemedShowMonthPicker.dart';
import 'package:coin_log/constants/MonthMap.dart';
import 'package:coin_log/objects/Record.dart';
import 'package:coin_log/services/RecordService.dart';

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
  List<List<DateTime?>> datesInMonth = [];
  RecordService _recordService = RecordService();

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
    final List<Record> records = await _recordService.listByYearMonth(widget.selectedDateTime.year.toString(), widget.selectedDateTime.month.toString().padLeft(2, "0"));
    // for(Record record in records) {
    //
    // }
  }

  @override
  void initState() {
    super.initState();
    datesInMonth = getDateListByYearMonth(widget.selectedDateTime.year, widget.selectedDateTime.month);

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
                RecordCalendarBody(columnWidth: columnWidth, datesInMonth: datesInMonth)
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
  List<List<DateTime?>> datesInMonth;

  RecordCalendarBody({
    super.key,
    required this.columnWidth,
    required this.datesInMonth
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
                    RecordCalendarBodyCell(width: widget.columnWidth, day: date?.day)
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
  final int? day;
  final double? expend;
  final double? income;

  RecordCalendarBodyCell({
    super.key,
    required this.width,
    this.day,
    this.expend,
    this.income
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {

      },
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6)
        ),
        width: width,
        height: 65,
        alignment: Alignment.center,
        child: day == null ?
          null :
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day.toString()),
              Column(
                children: [
                  if (expend != null) ... {
                    Text(
                      expend!.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.danger,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  },
                  if (income != null) ... {
                    Text(
                      income!.toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: 12,
                        color: Theme.of(context).colorScheme.success
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  }
                ],
              )
            ],
          ),
      ),
    );
  }
}