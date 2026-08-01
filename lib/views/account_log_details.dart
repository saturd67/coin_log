import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/main.dart';
import 'package:coin_log/models/AccountLog.dart';
import 'package:coin_log/services/AccountLogService.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/RecordService.dart';
import 'package:coin_log/views/base_view.dart';
import 'package:flutter/material.dart';

import '../constants/MonthMap.dart';
import '../constants/WeekMap.dart';
import '../models/Account.dart';
import '../models/Record.dart';
import '../services/TransactionCategoryService.dart';
import '../shared_widgets/themedShowMonthPicker.dart';
import '../utils/DateTimeFormatter.dart';

class AccountLogDetails extends StatefulWidget implements BaseView {
  static const classNameValue = 'AccountLogDetails';

  @override
  String get className => classNameValue;
  
  int identifier;
  
  AccountLogDetails({
    super.key,
    required this.identifier
  });
  
  @override
  State<AccountLogDetails> createState() => _AccountLogDetailsState();
}

class _AccountLogDetailsState extends State<AccountLogDetails> {

  AccountService _accountService = AccountService();
  AccountLogService _accountLogService = AccountLogService();
  RecordService _recordService = RecordService();
  TransactionCategoryService _transactionCategoryService = TransactionCategoryService();

  Account _account = Account(name: "", icon: "", sequence: 0, balance: 0, isDefault: false, isClosed: true);
  Map<String, List<AccountLog>> _groupedAccountLogs = {};

  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadAccount();
    loadAccountLog();
  }

  void loadAccount() async {
    Account? account = await _accountService.findById(widget.identifier);

    setState(() {
      _account = account!;
    });
  }

  void loadAccountLog() async {
    List<AccountLog> accountLogs = await _accountLogService.listByAccountIdYearMonth(widget.identifier, _selectedDateTime.year.toString(), _selectedDateTime.month.toString());

    Map<String, List<AccountLog>> groupedAccountLogs = {};
    for (AccountLog accountLog in accountLogs) {
      accountLog.record = await _recordService.findById(accountLog.recordId);

      if (accountLog.record != null) {
        if ([RecordType.income.name, RecordType.expense.name].contains(accountLog.record!.type)) {
          accountLog.record!.transactionCategory = await _transactionCategoryService.findById(accountLog.record!.transactionCategoryId!);
          accountLog.record!.sourceAccount = await _accountService.findById(accountLog.record!.sourceAccountId!);
        }

        else if (accountLog.record!.type == RecordType.transfer.name) {
          accountLog.record!.sourceAccount = await _accountService.findById(accountLog.record!.sourceAccountId!);
          accountLog.record!.destinationAccount = await _accountService.findById(accountLog.record!.destinationAccountId!);
        }
      }

      String formattedDate = "${DateTimeFormatter.toDayMonth(accountLog.recordDate)}  ${weekMap[accountLog.recordDate.weekday.toString()]}";
      if (!groupedAccountLogs.keys.contains(formattedDate)) {
        groupedAccountLogs.putIfAbsent(formattedDate, () => [accountLog]);
      }

      else {
        groupedAccountLogs[formattedDate]!.add(accountLog);
      }
    }

    setState(() {
      _groupedAccountLogs = groupedAccountLogs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
          shadowColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text("Account Balance Details")
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 15, 0),
            margin: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey, // shadow color
                  spreadRadius: 0,
                  blurRadius: 6,
                  offset: Offset(0, 3), // only bottom
                ),
              ]
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                            child: Icon(
                                getAccountIconData(_account.icon),
                                color: Theme.of(context).colorScheme.primary
                            ),
                          ),
                          Text(_account.name)
                        ],
                      ),
                      Text(_account.balance.toStringAsFixed(2))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: () async {
                              DateTime? tempDateTime = await themedShowMonthPicker(context, _selectedDateTime);
                              if (tempDateTime != null) {
                                setState(() {
                                  _selectedDateTime = tempDateTime;
                                });

                                loadAccountLog();
                              }
                            },
                            borderRadius: BorderRadius.circular(4),
                            splashColor: Colors.grey[300],
                            highlightColor: Colors.grey[300],
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                              child: Row(
                                children: [
                                  Text("${monthMap[_selectedDateTime.month.toString()]!} ${_selectedDateTime.year}"),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Theme.of(context).textTheme.bodyMedium!.color,
                                  )
                                ],
                              ),
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: ListView(
                children: [
                  for (var accountLog in _groupedAccountLogs.entries) ... {
                    AccountLogDay(date: accountLog.key, accountLogs: accountLog.value)
                  }
                ]
              ),
            ),
          ),
        ]
      )
    );
  }
}

class AccountLogDay extends StatefulWidget {

  String date;
  List<AccountLog> accountLogs;

  AccountLogDay({
    super.key,
    required this.date,
    required this.accountLogs
  });

  @override
  State<AccountLogDay> createState() => _AccountLogDayState();
}

class _AccountLogDayState extends State<AccountLogDay> {
  @override
  Widget build(BuildContext context) {
    Map<int, List<AccountLog>> groupedByRecord = {};
    List<int> recordOrder = [];
    for (AccountLog accountLog in widget.accountLogs) {
      if (!groupedByRecord.containsKey(accountLog.recordId)) {
        groupedByRecord[accountLog.recordId] = [];
        recordOrder.add(accountLog.recordId);
      }
      groupedByRecord[accountLog.recordId]!.add(accountLog);
    }

    return Container(
      child: Card(
        elevation: 2,
        color: Theme.of(context).colorScheme.secondary,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 0),
          child: Column(
            children: [
              AccountLogDayHeader(date: widget.date),
              Divider(
                height: 5,
              ),
              Column(
                children: [
                  for (int recordId in recordOrder) ... {
                    AccountLogRecordGroup(accountLogs: groupedByRecord[recordId]!)
                  }
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AccountLogRecordGroup extends StatefulWidget {

  final List<AccountLog> accountLogs;

  AccountLogRecordGroup({
    super.key,
    required this.accountLogs
  });

  @override
  State<AccountLogRecordGroup> createState() => _AccountLogRecordGroupState();
}

class _AccountLogRecordGroupState extends State<AccountLogRecordGroup> {

  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccountLogRecordHeader(
            accountLog: widget.accountLogs.first,
            expanded: _expanded,
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
          if (_expanded)
            for (AccountLog accountLog in widget.accountLogs) ... {
              AccountLogItem(accountLog: accountLog)
            }
        ],
      ),
    );
  }
}

class AccountLogRecordHeader extends StatelessWidget {

  final AccountLog accountLog;
  final bool expanded;
  final VoidCallback onTap;

  AccountLogRecordHeader({
    super.key,
    required this.accountLog,
    required this.expanded,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              accountLog.record == null
              ? Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                    child: Icon(
                      Icons.delete_forever,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  Text("Deleted", style: TextStyle(color: Theme.of(context).colorScheme.error),)
                ],
              )
              : [RecordType.income.name, RecordType.expense.name].contains(accountLog.record!.type)
              ? Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                    child: Icon(
                        getTransactionCategoryIconData(accountLog.record!.transactionCategory!.icon),
                    ),
                  ),
                  Text(accountLog.record!.transactionCategory!.name)
                ],
              )
              : [RecordType.transfer.name].contains(accountLog.record!.type)
              ? Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                    child: Icon(
                        getAccountIconData(accountLog.record!.sourceAccount!.icon),
                    ),
                  ),
                  Text(accountLog.record!.sourceAccount!.name),
                  Icon(Icons.arrow_forward),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                    child: Icon(
                        getAccountIconData(accountLog.record!.destinationAccount!.icon),
                    ),
                  ),
                  Text(accountLog.record!.destinationAccount!.name)
                ],
              )
              : Text("Error"),
              Icon(expanded ? Icons.expand_less : Icons.expand_more, 
              color: Theme.of(context).textTheme.bodyMedium!.color)
            ],
          ),
        ),
      ),
    );
  }
}

class AccountLogDayHeader extends StatelessWidget {

  String date;

  AccountLogDayHeader({
    required this.date
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
          child: Text(date),
        )
      ],
    );
  }
}

class AccountLogItem extends StatefulWidget {

  AccountLog accountLog;

  AccountLogItem({
    super.key,
    required this.accountLog
  });

  @override
  State<AccountLogItem> createState() => _AccountLogItemState();
}

class _AccountLogItemState extends State<AccountLogItem> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                  child: widget.accountLog.recordAction == RecordAction.insert.name
                    ? Icon(Icons.add, size: 24)
                    : widget.accountLog.recordAction == RecordAction.update.name
                    ? Icon(Icons.update, size: 24)
                    : widget.accountLog.recordAction == RecordAction.delete.name
                    ? Icon(Icons.close, size: 24, color: Theme.of(context).colorScheme.error,)
                    : Icon(Icons.question_mark, size: 24, color: Theme.of(context).colorScheme.error),
                ),
                Text(DateTimeFormatter.toTime(widget.accountLog.createdOn)),
              ]
            ),
            widget.accountLog.newBalance > widget.accountLog.oldBalance
            ? Text("+${(widget.accountLog.newBalance - widget.accountLog.oldBalance).abs().toStringAsFixed(2)}", style: TextStyle(color: Theme.of(context).colorScheme.success))
            : Text("-${(widget.accountLog.newBalance - widget.accountLog.oldBalance).abs().toStringAsFixed(2)}", style: TextStyle(color: Theme.of(context).colorScheme.error))
          ]
      ),
    );
  }
}