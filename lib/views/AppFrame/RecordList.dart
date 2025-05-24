import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/objects/TransactionCategory.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/main.dart';

import 'package:coin_log/objects/Record.dart';
import 'package:coin_log/services/RecordService.dart';

import 'package:coin_log/constants/WeekMap.dart';

class RecordList extends StatefulWidget {
  const RecordList({Key? key}) : super(key: key);

  @override
  State<RecordList> createState() => RecordListState();
}

class RecordListState extends State<RecordList> {
  TransactionCategoryService _transactionCategoryService = TransactionCategoryService();
  AccountService _accountService = AccountService();
  RecordService _recordService = RecordService();

  Map<String, GroupedRecordItem> groupedRecords = <String, GroupedRecordItem>{};

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final List<Record> records = await _recordService.listByYearMonth("2025", "05");
    Map<String, GroupedRecordItem> groupedRecords = <String, GroupedRecordItem>{};

    for (Record record in records) {
      record.transactionCategory = await _transactionCategoryService.findById(record.transactionCategoryId);
      record.account = await _accountService.findById(record.accountId);

      String formattedDate = "${record.date.month}/${record.date.day}  ${weekMap[record.date.weekday.toString()]}";

      double income = record.type == "Income" ? record.amount : 0;
      double expense = record.type == "Expense" ? record.amount : 0;

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
      this.groupedRecords = groupedRecords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var record in groupedRecords.entries) ... {
          RecordDay(date: record.key, groupedRecordItem: record.value)
        }
      ]
    );
  }
}

class RecordDay extends StatefulWidget {
  String date;
  GroupedRecordItem groupedRecordItem;

  RecordDay({
    super.key,
    required this.date,
    required this.groupedRecordItem
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
                      RecordDayBodyItem(iconData: record.transactionCategory!.icon, name: record.transactionCategory!.name, type: record.type, amount: record.amount.toStringAsFixed(2))
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

class RecordDayBodyItem extends StatefulWidget {
  String iconData;
  String name;
  String type;
  String amount;

  RecordDayBodyItem({
    super.key,
    required this.iconData,
    required this.name,
    required this.type,
    required this.amount
  });

  @override
  State<RecordDayBodyItem> createState() => _RecordDayBodyItemState();
}

class _RecordDayBodyItemState extends State<RecordDayBodyItem> {
  @override
  Widget build(BuildContext context) {
    return Align(
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
                        coinLogTransactionCategoryIconMap[widget.iconData]!.icon,
                        color: Color(0xFFFFD700),
                        size: 30,
                      ),
                    ),
                    Text(widget.name),
                  ],
                ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {},
                child: Container(
                  width:
                      MediaQuery.sizeOf(context).width * 0.32,
                  height: 50,
                  decoration: BoxDecoration(),
                  alignment: AlignmentDirectional(1, 0),
                  child: Text(
                    widget.type == "Income" ? "+${widget.amount}" : widget.type == "Expense" ? "-${widget.amount}" : "",
                    style: TextStyle(
                      color: widget.type == "Income" ? Theme.of(context).colorScheme.success : widget.type == "Expense" ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecordDayBodyItemDetail extends StatelessWidget {
  const RecordDayBodyItemDetail({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width:
                MediaQuery.sizeOf(context).width * 0.05,
            decoration: BoxDecoration(),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                decoration: BoxDecoration(),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context)
                              .width *
                          0.58,
                      decoration: BoxDecoration(),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional
                                .fromSTEB(0, 0, 10, 0),
                            child: Icon(
                              Icons
                                  .account_balance_wallet_rounded,
                              color: Color(0xFF0035FF),
                              size: 24,
                            ),
                          ),
                          Text(
                            'Tng E-Wallet'
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context)
                              .width *
                          0.32,
                      decoration: BoxDecoration(),
                      child: Text(
                        '500.00',
                        textAlign: TextAlign.end
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context)
                              .width *
                          0.58,
                      decoration: BoxDecoration(),
                      alignment:
                          AlignmentDirectional(1, 0),
                      child: Text(
                        'Balance: '
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context)
                              .width *
                          0.32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                        ),
                      ),
                      child: Align(
                        alignment:
                            AlignmentDirectional(1, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Divider(
                              height: 5,
                            ),
                            Text(
                              '400.00',
                              textAlign: TextAlign.end
                            ),
                            Divider(
                              height: 2,
                            ),
                            Divider(
                              height: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecordDayBodyItemExample1 extends StatelessWidget {
  const RecordDayBodyItemExample1({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0, 0),
      child: Container(
        height: 45,
        decoration: BoxDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Align(
              alignment: AlignmentDirectional(0, -1),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.63,
                height: 50,
                decoration: BoxDecoration(),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          0, 0, 10, 0),
                      child: Icon(
                        Icons.dinner_dining,
                        color: Color(0xFFFFD700),
                        size: 30,
                      ),
                    ),
                    Text(
                      'Dinner',
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.sizeOf(context).width * 0.32,
              height: 50,
              decoration: BoxDecoration(),
              alignment: AlignmentDirectional(1, 0),
              child: Text(
                '-100.00',
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

class GroupedRecordItem {
  late double sumIncome;
  late double sumExpense;
  late List<Record> records;

  GroupedRecordItem(this.sumIncome, this.sumExpense, this.records);
}
