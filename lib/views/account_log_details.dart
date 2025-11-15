import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/models/AccountLog.dart';
import 'package:coin_log/services/AccountLogService.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/RecordService.dart';
import 'package:flutter/material.dart';

import '../constants/MonthMap.dart';
import '../constants/WeekMap.dart';
import '../models/Account.dart';
import '../models/Record.dart';
import '../services/TransactionCategoryService.dart';
import '../shared_widgets/themedShowMonthPicker.dart';
import '../shared_widgets/themed_text_field.dart';
import '../utils/DateTimeFormatter.dart';

class AccountLogDetails extends StatefulWidget {
  
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
    load();
  }

  void load() async {
    Account? account = await _accountService.findById(widget.identifier);

    setState(() {
      _account = account!;
    });

    List<AccountLog> accountLogs = await _accountLogService.listByAccountIdYearMonth(widget.identifier, _selectedDateTime.year.toString(), _selectedDateTime.month.toString());
    print("accountLogs length: ${accountLogs.length}");

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
      body: Container(
        color: Theme.of(context).colorScheme.secondary,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 15, 15, 10),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.tertiary
                      ),
                      child: Icon(
                          getAccountIconData(_account.icon),
                          size: Theme.of(context).iconTheme.size,
                          color: Theme.of(context).colorScheme.onSecondary
                      ),
                    ),
                  ),
                  Text(_account.name)
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 15, 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: () async {
                          DateTime? tempDateTime = await themedShowMonthPicker(context, _selectedDateTime);
                          if (tempDateTime != null) {
                            setState(() {
                              _selectedDateTime = tempDateTime;
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
                ),
              ],
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
        ),
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
                  for (AccountLog accountLog in widget.accountLogs) ... {
                    AccountLogItem(accountLog: accountLog)
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
      height: 50,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                  child: Icon(
                      Icons.ac_unit,
                      size: 30.0
                  ),
                ),
                Text("Test")
              ],
            ),
            Text("10.00")
          ]
      ),
    );
  }
}