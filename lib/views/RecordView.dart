import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/objects/Account.dart';
import 'package:coin_log/objects/TransactionCategory.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/RecordService.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/utils/DateTimeFormatter.dart';
import 'package:flutter/material.dart';

import 'package:coin_log/objects/Record.dart';

import '../widgets/showConfirmationDialog.dart';

class RecordView extends StatefulWidget {
  final int identifier;

  RecordView({
    super.key,
    required this.identifier
  });

  @override
  State<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  final RecordService _recordService = RecordService();
  final TransactionCategoryService _transactionCategoryService = TransactionCategoryService();
  final AccountService _accountService = AccountService();

  Record _record = Record(transactionCategoryId: 0, accountId: 0, date: DateTime.now(), type: "", amount: 0.0);

  @override
  void initState() {
    super.initState();

    _record.transactionCategory = TransactionCategory(name: "", icon: "", type: "", sequence: 0, isDeleted: false);
    _record.account = Account(name: "", icon: "", sequence: 0, balance: 0.0, isDefault: false, isDeleted: false);

    load();
  }

  void load() async {
    Record? record = await _recordService.findById(widget.identifier);
    if (record != null) {
      TransactionCategory? transactionCategory = await _transactionCategoryService.findById(record.transactionCategoryId);
      if (transactionCategory != null) {
        record.transactionCategory = transactionCategory;
      }

      Account? account = await _accountService.findById(record.accountId);
      if (account != null) {
        record.account = account;
      }

      setState(() {
        _record = record;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            shadowColor: Theme.of(context).colorScheme.surface,
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text("Account View"),
          ),
          body: Container(
            color: Theme.of(context).colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    color: Theme.of(context).colorScheme.secondary,

                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(10, 15, 15, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
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
                                        child: Icon(coinLogTransactionCategoryIconMap[_record.transactionCategory!.icon]?.icon, size: Theme.of(context).iconTheme.size),
                                      ),
                                    ),
                                    Text(_record.transactionCategory!.name)
                                  ],
                                ),
                              ),
                              Text(_record.getFormattedAmount())
                            ],
                          ),
                        ],
                      ),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0,10,0,0),
                    child: Table(
                      columnWidths: const<int, TableColumnWidth> {
                        0: FixedColumnWidth(110.0),
                        1: FlexColumnWidth(),
                      },
                      children: [
                        TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("From:"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(_record.account!.name),
                              )
                            ]
                        ),
                        TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Date:"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(DateTimeFormatter.toDate(_record.date)),
                              )
                            ]
                        ),
                        TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Description:"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(_record.description == null ? "-" : _record.description!),
                              )
                            ]
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              border: Border(top: BorderSide(
                color: Theme.of(context).colorScheme.surface,
                width: 1.0
              ))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showConfirmationDialog(
                          context,
                          "Are you sure you want to delete?",
                              () async {
                            await _recordService.delete(_record.identifier!);
                            Navigator.of(context).pop("reload");
                          },
                              () {});
                    },
                    child: Container(
                      height: double.infinity,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                          SizedBox(width:4),
                          Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.error),)
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      //
                    },
                    child: Container(
                      height: double.infinity,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width:4),
                          Text("Edit")
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}