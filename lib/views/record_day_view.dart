import 'package:coin_log/main.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/RecordService.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/views/record_details.dart';
import 'package:coin_log/views/record_view.dart';
import 'package:coin_log/views/base_view.dart';
import 'package:flutter/material.dart';

import '../constants/IconMap.dart';
import '../constants/WeekMap.dart';
import '../models/Record.dart';
import '../router/RouterUtils.dart';
import '../utils/DateTimeFormatter.dart';

class RecordDayView extends StatefulWidget implements BaseView {
  static const classNameValue = 'RecordDayView';

  @override
  String get className => classNameValue;

  DateTime date;

  RecordDayView({
    required this.date
  });

  @override
  State<RecordDayView> createState() => _RecordDayViewState();
}

class _RecordDayViewState extends State<RecordDayView> {

  RecordService _recordService = RecordService();
  TransactionCategoryService _transactionCategoryService = TransactionCategoryService();
  AccountService _accountService = AccountService();

  String _formattedDate = '';
  double _sumIncome = 0;
  double _sumExpense= 0;
  List<Record_> _records = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    _formattedDate = "${DateTimeFormatter.toDayMonth(widget.date)}  ${weekMap[widget.date.weekday.toString()]}";

    double sumIncome = 0;
    double sumExpense = 0;
    final List<Record_> records = await _recordService.listByYearMonthDay(widget.date.year.toString(), widget.date.month.toString(), widget.date.day.toString());

    for (Record_ record in records) {
      if ([RecordType.income.name, RecordType.expense.name].contains(record.type)) {
        record.transactionCategory = await _transactionCategoryService.findById(record.transactionCategoryId!);
        record.sourceAccount = await _accountService.findById(record.sourceAccountId!);

        sumIncome += record.type == RecordType.income.name ? record.amount : 0;
        sumExpense += record.type == RecordType.expense.name ? record.amount : 0;
      }

      else if (record.type == RecordType.transfer.name) {
        record.sourceAccount = await _accountService.findById(record.sourceAccountId!);
        record.destinationAccount = await _accountService.findById(record.destinationAccountId!);
      }
    }

    setState(() {
      _sumIncome = sumIncome;
      _sumExpense = sumExpense;
      _records = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (canPop, result) {
        if (!canPop) {
          Navigator.of(context).pop("reload");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Record"),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop("reload");
              },
              icon: Icon(Icons.arrow_back)
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add
          ),
          onPressed: () async {
            final results = await Navigator.of(context).push(RouterUtils.createRoute(RecordDetails(returnTo: RecordDayView.classNameValue, defaultDateTime: widget.date)));
            if (results != null && results.length > 1 && results[0] == "reload") {
              load();
            }
          }
        ),
        body: Column(
          children: [
            Card(
              elevation: 1,
              color: Theme.of(context).colorScheme.secondary,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(7, 0, 7, 0),
                child: Column(
                  children: [
                    RecordDayHeader(date: _formattedDate, sumIncome: _sumIncome.toStringAsFixed(2), sumExpense: _sumExpense.toStringAsFixed(2)),
                    Divider(
                      height: 5,
                    ),
                    Column(
                      children: [
                        for (Record_ record in _records) ... {
                          if ([RecordType.expense.name, RecordType.income.name].contains(record.type)) ... {
                            TransactionRecordDayBodyItem(record: record, load: load)
                          }

                          else if (record.type == RecordType.transfer.name) ... {
                            TransferRecordDayBodyItem(record: record, load: load)
                          }
                        }
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordDayHeader extends StatelessWidget {

  String date;
  String sumIncome;
  String sumExpense;

  RecordDayHeader({
    required this.date,
    required this.sumIncome,
    required this.sumExpense
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
      child: SizedBox(
        height: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 100,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                    child: Text(date),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  width: 90,
                  alignment: AlignmentDirectional(1, 0),
                  child: Text(
                    '+$sumIncome',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.success
                    ),
                  ),
                ),
                Container(
                  width: 90,
                  alignment: AlignmentDirectional(1, 0),
                  child: Text(
                    '-$sumExpense',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.danger
                    ),
                  ),
                )
              ],
            )
          ],
        )
      ),
    );
  }
}

class TransactionRecordDayBodyItem extends StatefulWidget {
  Record_ record;
  void Function() load;

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
        final result = await Navigator.of(context).push(RouterUtils.createRoute(RecordView(returnTo: RecordDayView.classNameValue, identifier: widget.record.identifier!,)));
        if (result == "reload") {
          widget.load();
        }
      },
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                  child: Stack(
                      children: [
                        Icon(
                          getTransactionCategoryIconData(widget.record.transactionCategory!.icon),
                        ),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3)
                              ),
                              child: Icon(
                                  getAccountIconData(widget.record.sourceAccount!.icon),
                                  color: Color(0xffFFD700),
                                  size: 15
                              ),
                            )
                        )
                      ]
                  ),
                ),
                Text(widget.record.transactionCategory!.name),
              ],
            ),
            Container(
              alignment: AlignmentDirectional(1, 0),
              child: Text(
                widget.record.type == RecordType.income.name ? "+${widget.record.amount}" : widget.record.type == RecordType.expense.name ? "-${widget.record.amount}" : "",
                style: TextStyle(
                  color: widget.record.type == RecordType.income.name ? Theme.of(context).colorScheme.success : widget.record.type == RecordType.expense.name ? Theme.of(context).colorScheme.danger : Theme.of(context).colorScheme.danger,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransferRecordDayBodyItem extends StatefulWidget {
  Record_ record;
  void Function() load;

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
        final result = await Navigator.of(context).push(RouterUtils.createRoute(RecordView(returnTo: RecordDayView.classNameValue, identifier: widget.record.identifier!,)));
        if (result == "reload") {
          widget.load();
        }
      },
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                  child: Icon(
                    getAccountIconData(widget.record.sourceAccount!.icon),
                  ),
                ),
                Text(widget.record.sourceAccount!.name),
                Icon(Icons.arrow_forward),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                  child: Icon(
                    getAccountIconData(widget.record.destinationAccount!.icon),
                  ),
                ),
                Text(widget.record.destinationAccount!.name),
              ],
            ),
            Text(
                widget.record.amount.toString(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.success
                )
            ),
          ],
        ),
      ),
    );
  }
}