import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/main.dart';
import 'package:coin_log/models/Account.dart';
import 'package:coin_log/models/TransactionCategory.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/RecordService.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/utils/DateTimeFormatter.dart';
import 'package:flutter/material.dart';

import 'package:coin_log/models/Record.dart';

import '../router/RouterUtils.dart';
import '../shared_widgets/showConfirmationDialog.dart';
import 'record_details.dart';

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

  Record_ _record = Record_(transactionCategoryId: 0, sourceAccountId: 0, date: DateTime.now(), type: "", amount: 0.0);

  @override
  void initState() {
    super.initState();

    _record.transactionCategory = TransactionCategory(name: "", icon: "", type: "", sequence: 0, isClosed: false);
    _record.sourceAccount = Account(name: "", icon: "", sequence: 0, balance: 0.0, isDefault: false, isClosed: false);
    _record.destinationAccount = Account(name: "", icon: "", sequence: 0, balance: 0.0, isDefault: false, isClosed: false);

    load();
  }

  void load() async {
    Record_? record = await _recordService.findById(widget.identifier);
    if (record != null) {
      if ([RecordType.expense.name, RecordType.income.name].contains(record.type)) {
        TransactionCategory transactionCategory = (await _transactionCategoryService.findById(record.transactionCategoryId!))!;
        record.transactionCategory = transactionCategory;

        Account account = (await _accountService.findById(record.sourceAccountId!))!;
        record.sourceAccount = account;
      }

      else if (record.type == RecordType.transfer.name) {
        Account sourceAccount = (await _accountService.findById(record.sourceAccountId!))!;
        record.sourceAccount = sourceAccount;

        Account destinationAccount = (await _accountService.findById(record.destinationAccountId!))!;
        record.destinationAccount = destinationAccount;
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
            title: const Text("Record View"),
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
                              if ([RecordType.expense.name, RecordType.income.name].contains(_record.type)) ... {
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
                                          child: Icon(
                                              getTransactionCategoryIconData(_record.transactionCategory!.icon),
                                              size: Theme.of(context).iconTheme.size,
                                              color: Theme.of(context).colorScheme.onSecondary
                                          ),
                                        ),
                                      ),
                                      Text(_record.transactionCategory!.name)
                                    ],
                                  ),
                                ),
                              },
                              if (_record.type == RecordType.transfer.name) ... {
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
                                          child: Icon(getAccountIconData(_record.sourceAccount!.icon),
                                              size: Theme.of(context).iconTheme.size,
                                              color: Theme.of(context).colorScheme.onSecondary
                                          ),
                                        ),
                                      ),
                                      Text(_record.sourceAccount!.name),
                                      Icon(Icons.arrow_forward),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                                        child: Container(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context).colorScheme.tertiary
                                          ),
                                          child: Icon(getAccountIconData(_record.destinationAccount!.icon),
                                            size: Theme.of(context).iconTheme.size,
                                            color: Theme.of(context).colorScheme.onSecondary
                                          ),
                                        ),
                                      ),
                                      Text(_record.destinationAccount!.name),
                                    ],
                                  ),
                                ),
                              },
                              Text( _record.type == RecordType.income.name ? "+${_record.amount.toStringAsFixed(2)}" : "-${_record.amount.toStringAsFixed(2)}", style: TextStyle(color: _record.type == RecordType.income.name ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.danger),)
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
                        0: FixedColumnWidth(120.0),
                        1: FlexColumnWidth(),
                      },
                      children: [
                        TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("${_record.type == RecordType.income.name ? "To" : "From"}:"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(_record.sourceAccount!.name),
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
                  child: InkWell(
                    onTap: () {
                      showConfirmationDialog(
                          context,
                          "Are you sure you want to delete?",
                              () async {
                            if ([RecordType.expense.name, RecordType.income.name].contains(_record.type)) {
                              await _recordService.deleteTransaction(_record);
                            }

                            else if (_record.type == RecordType.transfer.name) {
                              await _recordService.deleteTransfer(_record);
                            }

                            Navigator.of(context).pop("reload");
                          }, () {});
                    },
                    child: Container(
                      height: double.infinity,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, color: Theme.of(context).colorScheme.danger),
                          SizedBox(width:4),
                          Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.danger),)
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(RouterUtils.createRoute(RecordDetails(identifier: _record.identifier)));
                    },
                    child: Container(
                      height: double.infinity,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.onSecondary
                          ),
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