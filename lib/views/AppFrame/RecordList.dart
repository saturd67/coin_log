import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/constants/MonthMap.dart';
import 'package:coin_log/router/RouterUtils.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/views/RecordView.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/main.dart';
import 'package:coin_log/objects/Record.dart';
import 'package:coin_log/services/RecordService.dart';
import 'package:coin_log/constants/WeekMap.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:coin_log/utils/DateTimeFormatter.dart';

class RecordList extends StatefulWidget {
  const RecordList({Key? key}) : super(key: key);

  @override
  State<RecordList> createState() => RecordListState();
}

class RecordListState extends State<RecordList> {
  TransactionCategoryService _transactionCategoryService = TransactionCategoryService();
  AccountService _accountService = AccountService();
  RecordService _recordService = RecordService();

  Map<String, GroupedRecordItem> _groupedRecords = <String, GroupedRecordItem>{};
  DateTime _selectedDate = DateTime.now();
  double _totalIncome = 0;
  double _totalExpense = 0;

  @override
  void initState() {
    super.initState();
    load(_selectedDate);
  }

  void load(DateTime selectedDateTime) async {
    final List<Record> records = await _recordService.listByYearMonth(selectedDateTime.year.toString(), selectedDateTime.month.toString().padLeft(2, "0"));
    Map<String, GroupedRecordItem> groupedRecords = <String, GroupedRecordItem>{};

    double totalIncome = 0;
    double totalExpense = 0;
    for (Record record in records) {
      String formattedDate = "${DateTimeFormatter.toDayMonth(record.date)}  ${weekMap[record.date.weekday.toString()]}";

      double income = 0;
      double expense = 0;

      if (["Income", "Expense"].contains(record.type)) {
        record.transactionCategory = await _transactionCategoryService.findById(record.transactionCategoryId!);
        record.sourceAccount = await _accountService.findById(record.sourceAccountId!);


        income = record.type == "Income" ? record.amount : 0;
        totalIncome += income;

        expense = record.type == "Expense" ? record.amount : 0;
        totalExpense += expense;
      }

      else if (record.type == "Transfer") {
        record.sourceAccount = await _accountService.findById(record.sourceAccountId!);
        record.destinationAccount = await _accountService.findById(record.destinationAccountId!);
      }

      if (!groupedRecords.keys.contains(formattedDate)) {
        groupedRecords.putIfAbsent(formattedDate, () => GroupedRecordItem(income, expense, [record]));
      }

      else {
        groupedRecords[formattedDate]!.sumIncome += income;
        groupedRecords[formattedDate]!.sumExpense += expense;
        groupedRecords[formattedDate]!.records.add(record);
      }
    }

    setState(() {
      _selectedDate = selectedDateTime;
      _totalIncome = totalIncome;
      _totalExpense = totalExpense;
      _groupedRecords = groupedRecords;
    });
  }

  void onDateTimeChange() async {
    DateTime? selectedDate = await showMonthPicker(
      context: context,
      monthPickerDialogSettings: MonthPickerDialogSettings(
          dialogSettings: PickerDialogSettings(
              dialogBackgroundColor: Theme.of(context).colorScheme.secondary
          ),
          headerSettings: PickerHeaderSettings(
              headerBackgroundColor: Theme.of(context).colorScheme.primary,
              headerCurrentPageTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: Theme.of(context).textTheme.headlineLarge!.fontSize
              )
          ),
          dateButtonsSettings: PickerDateButtonsSettings(
              currentYearTextColor: Theme.of(context).colorScheme.onSecondary,
              currentMonthTextColor: Theme.of(context).colorScheme.onSecondary,
              unselectedYearsTextColor: Theme.of(context).textTheme.bodyMedium!.color,
              unselectedMonthsTextColor: Theme.of(context).textTheme.bodyMedium!.color,
              selectedYearTextColor: Theme.of(context).colorScheme.primary,
              selectedMonthTextColor: Theme.of(context).colorScheme.primary
          )
      ),
      initialDate: _selectedDate,
      firstDate: DateTime(2001),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });

      load(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          shadowColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: RecordsAppBar(selectedDateTime: _selectedDate, totalIncome: _totalIncome, totalExpense: _totalExpense, onDateTimeChange: onDateTimeChange)
      ),
      body: ListView(
        children: [
          for (var record in _groupedRecords.entries) ... {
            RecordDay(date: record.key, groupedRecordItem: record.value, load: load)
          }
        ]
      ),
    );
  }
}

class RecordsAppBar extends StatefulWidget {
  DateTime selectedDateTime;
  double totalIncome;
  double totalExpense;
  Function() onDateTimeChange;

  RecordsAppBar({
    super.key,
    required this.selectedDateTime,
    required this.totalIncome,
    required this.totalExpense,
    required this.onDateTimeChange
  });

  @override
  State<RecordsAppBar> createState() => _RecordsAppBarState();
}

class _RecordsAppBarState extends State<RecordsAppBar> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.onDateTimeChange,
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedDateTime.year.toString(),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    monthMap[widget.selectedDateTime.month.toString()]!,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500
                    ),
                  )
                ]
            ),
          ),
          Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Income:',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  '+${widget.totalIncome.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                  ),
                )
              ]
          ),
          Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expenses:',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  '-${widget.totalExpense.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                  ),
                )
              ]
          ),
          Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance:',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  (widget.totalIncome - widget.totalExpense).toStringAsFixed(2),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                  ),
                )
              ]
          )
        ],
      ),
    );
  }
}

class RecordDay extends StatefulWidget {
  String date;
  GroupedRecordItem groupedRecordItem;
  final void Function(DateTime) load;

  RecordDay({
    super.key,
    required this.date,
    required this.groupedRecordItem,
    required this.load
  });

  @override
  State<RecordDay> createState() => _RecordDayState();
}

class _RecordDayState extends State<RecordDay> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Theme.of(context).colorScheme.secondary,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
            ),
            shape: BoxShape.rectangle,
          ),
          alignment: AlignmentDirectional(0, -1),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecordDayHeader(date: widget.date, sumIncome: widget.groupedRecordItem.sumIncome.toStringAsFixed(2), sumExpense: widget.groupedRecordItem.sumExpense.toStringAsFixed(2)),
              Divider(
                height: 5,
              ),
              Column(
                children: [
                  for (var record in widget.groupedRecordItem.records) ... {
                    if (["Expense", "Income"].contains(record.type)) ... {
                      TransactionRecordDayBodyItem(record: record, load: widget.load)
                    }

                    else if (record.type == "Transfer") ... {
                      TransferRecordDayBodyItem(record: record, load: widget.load)
                    }
                  }
                ]
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RecordDayHeader extends StatefulWidget {
  String date;
  String sumIncome;
  String sumExpense;

  RecordDayHeader({
    super.key,
    required this.date,
    required this.sumIncome,
    required this.sumExpense
  });

  @override
  State<RecordDayHeader> createState() => _RecordDayHeaderState();
}

class _RecordDayHeaderState extends State<RecordDayHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
      child: Container(
        height: 20,
        decoration: BoxDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width * 0.3,
              decoration: BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                    child: Text(widget.date),
                  )
                ],
              ),
            ),
            Container(
              width: MediaQuery.sizeOf(context).width * 0.32,
              height: 100,
              decoration: BoxDecoration(),
              alignment: AlignmentDirectional(1, 0),
              child: Text(
                '+${widget.sumIncome}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.success
                ),
              ),
            ),
            Container(
              width: MediaQuery.sizeOf(context).width * 0.32,
              height: 100,
              decoration: BoxDecoration(),
              alignment: AlignmentDirectional(1, 0),
              child: Text(
                '-${widget.sumExpense}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionRecordDayBodyItem extends StatefulWidget {
  Record record;
  void Function(DateTime) load;

  TransactionRecordDayBodyItem({
    super.key,
    required this.record,
    required this.load
  });

  @override
  State<TransactionRecordDayBodyItem> createState() => _TransactionRecordDayBodyItemState();
}

class _TransactionRecordDayBodyItemState extends State<TransactionRecordDayBodyItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.of(context).push(RouterUtils.createRoute(RecordView(identifier: widget.record.identifier!,)));
        if (result == "reload") {
          widget.load(widget.record.date);
        }
      },
      child: Align(
        alignment: AlignmentDirectional(0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width:
                      MediaQuery.sizeOf(context).width * 0.63,
                  height: 50,
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0, 0, 10, 0),
                        child: Icon(
                          coinLogTransactionCategoryIconMap[widget.record.transactionCategory!.icon]!.icon,
                          color: Color(0xFFFFD700),
                          size: 30,
                        ),
                      ),
                      Text(widget.record.transactionCategory!.name),
                    ],
                  ),
                ),
                Container(
                  width:
                      MediaQuery.sizeOf(context).width * 0.32,
                  height: 50,
                  decoration: BoxDecoration(),
                  alignment: AlignmentDirectional(1, 0),
                  child: Text(
                    widget.record.type == "Income" ? "+${widget.record.amount}" : widget.record.type == "Expense" ? "-${widget.record.amount}" : "",
                    style: TextStyle(
                      color: widget.record.type == "Income" ? Theme.of(context).colorScheme.success : widget.record.type == "Expense" ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TransferRecordDayBodyItem extends StatefulWidget {
  Record record;
  void Function(DateTime) load;

  TransferRecordDayBodyItem({
    super.key,
    required this.record,
    required this.load
  });
  
  @override
  State<TransferRecordDayBodyItem> createState() => _TransferRecordDayBodyItemState();
}

class _TransferRecordDayBodyItemState extends State<TransferRecordDayBodyItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // final result = await Navigator.of(context).push(RouterUtils.createRoute(RecordView(identifier: widget.record.identifier!,)));
        // if (result == "reload") {
        //   widget.load(widget.record.date);
        // }
      },
      child: Align(
        alignment: AlignmentDirectional(0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width:
                  MediaQuery.sizeOf(context).width * 0.63,
                  height: 50,
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0, 0, 10, 0),
                        child: Icon(
                          coinLogAccountIconMap[widget.record.sourceAccount!.icon]!.icon,
                          color: Color(0xFFFFD700),
                          size: 30,
                        ),
                      ),
                      Text(widget.record.sourceAccount!.name),
                      Icon(Icons.arrow_forward),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0, 0, 10, 0),
                        child: Icon(
                          coinLogAccountIconMap[widget.record.destinationAccount!.icon]!.icon,
                          color: Color(0xFFFFD700),
                          size: 30,
                        ),
                      ),
                      Text(widget.record.destinationAccount!.name),
                    ],
                  ),
                ),
                Container(
                  width:
                  MediaQuery.sizeOf(context).width * 0.32,
                  height: 50,
                  decoration: BoxDecoration(),
                  alignment: AlignmentDirectional(1, 0),
                  child: Text(
                    widget.record.amount.toStringAsFixed(2),
                  ),
                ),
              ],
            ),
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
