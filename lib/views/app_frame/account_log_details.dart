import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/models/AccountLog.dart';
import 'package:coin_log/services/AccountLogService.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:flutter/material.dart';

import '../../constants/MonthMap.dart';
import '../../models/Account.dart';
import '../../shared_widgets/themedShowMonthPicker.dart';
import '../../shared_widgets/themed_text_field.dart';

class AccountLogDetails extends StatefulWidget {
  
  int identifier;
  
  AccountLogDetails({
    required this.identifier
  });
  
  @override
  State<AccountLogDetails> createState() => _AccountLogDetailsState();
}

class _AccountLogDetailsState extends State<AccountLogDetails> {

  AccountService _accountService = AccountService();
  AccountLogService _accountLogService = AccountLogService();

  late Account _account;
  List<AccountLog> _accountLogs = [];

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

    // List<AccountLog> accountLogs = await _accountLogService.listByAccountId(widget.identifier);
    // setState(() {
    //   _accountLogs = accountLogs;
    // });
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
            Card(
              elevation: 2,
              color: Theme.of(context).colorScheme.secondary,
              child: Padding(
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
            )
            // ListView(
            //   children: List.generate(_accountLogs.length, (index) {
            //     return AccountLogItem(icon: icon, name: name, amount: amount)
            //   })
            // ),
          ]
        ),
      )
    );
  }
}

class AccountLogItem extends StatelessWidget {
  IconData icon;
  String name;
  double amount;

  AccountLogItem({
    super.key,
    required this.icon,
    required this.name,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      height: 65,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                      child: Icon(
                          icon,
                          size: 30.0
                      ),
                    ),
                    Text(name)
                  ],
                ),
                Text(amount.toStringAsFixed(2))
              ]
          )
      ),
    );
  }
}