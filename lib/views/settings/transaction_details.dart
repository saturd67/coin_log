import 'package:coin_log/form_models/TransactionCategoryFormModel.dart';
import 'package:coin_log/models/TransactionCategory.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/shared_widgets/themed_text_field.dart';
import 'package:coin_log/shared_widgets/themed_toast.dart';
import 'package:coin_log/shared_widgets/showConfirmationDialog.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/shared_widgets/grid_view_icon.dart';
import 'package:coin_log/shared_widgets/switch_button.dart';
import 'package:coin_log/constants/IconMap.dart';
import 'package:logging/logging.dart';

import '../../models/Record.dart';

class TransactionDetails extends StatefulWidget {

  final int? identifier;

  TransactionDetails({
    super.key,
    this.identifier
  });

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  final _log = Logger('TransactionDetails');
  final TransactionCategoryService transactionCategoryService = TransactionCategoryService();

  int? _identifier;
  TransactionCategoryFormModel _transactionCategoryFormModel = TransactionCategoryFormModel(type: RecordType.expense.name, sequence: 1, isClosed: false);
  IconData? onDisplayIconData;

  @override
  void initState() {
    super.initState();
    _identifier = widget.identifier;

    if (widget.identifier != null) {
      load();
    }
  }

  void load() async {
    final transactionCategory = await transactionCategoryService.findById(widget.identifier!);

    if (transactionCategory != null) {
      setState(() {
        _transactionCategoryFormModel = transactionCategory.toFormModel();
        onDisplayIconData = getTransactionCategoryIconData(_transactionCategoryFormModel.icon);
      });
    }
  }

  @override
  void dispose() {
    _transactionCategoryFormModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Transaction Details"),
          actions: [
            IconButton(
              onPressed: () async {

                TransactionCategory transactionCategory;
                try {
                  transactionCategory = _transactionCategoryFormModel.toModel();
                }

                catch (e) {
                  ThemedToast.showToast(e as String);
                  return;
                }

                if (_identifier == null) {
                  int? identifier = await transactionCategoryService.save(transactionCategory);
                  transactionCategory.identifier = identifier;

                  _log.info("Saved ${transactionCategory.toMap()}");
                }

                else {
                  int? identifier = await transactionCategoryService.update(transactionCategory);

                  _log.info("Updated ${transactionCategory.toMap()}");
                }

                Navigator.of(context).pop("reload");
              }, 
              icon: const Icon(Icons.check)
            )
          ],
        ),
        body: Container(
          color: Theme.of(context).colorScheme.secondary,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(2.0, 12.0, 12.0, 10.0),
                child: Row(
                  children: [
                    Container(
                      width: 65,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: onDisplayIconData != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary
                      ),
                      child: Icon(onDisplayIconData ?? Icons.picture_in_picture, color: onDisplayIconData != null ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).iconTheme.color),
                    ),
                    Expanded(
                      child: ThemedTextField(
                        placeholder: "Name",
                        maxLength: 10,
                        controller: _transactionCategoryFormModel.nameController,
                      )
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SwitchButton(
                      labels: [RecordType.expense.name, RecordType.income.name],
                      selectedValue: _transactionCategoryFormModel.type!,
                      onChanged: (value) {
                        _transactionCategoryFormModel.type = value;
                      }
                    ),
                    if (_identifier != null)
                      IconButton(
                          onPressed: () async {
                            showConfirmationDialog(
                                context,
                                "Are you sure you want to delete?",
                                    () async {
                                    await transactionCategoryService.delete(_identifier!);
                                    Navigator.of(context).pop("reload");
                                  },
                                    () {});
                            // await transactionCategoryService.delete(_identifier!);
                            // Navigator.of(context).pop("reload");
                          },
                          icon: Icon(Icons.delete, color: Color(0xffff0000))
                      )
                  ],
                )
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: getGroupedIcons(transactionCategoryIconMap).entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                              child: Text(entry.key.value.toString())
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 100,
                              crossAxisSpacing: 2.0,
                              mainAxisSpacing: 2.0,
                              childAspectRatio: 1,
                            ),
                            itemCount: entry.value.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _transactionCategoryFormModel.icon = entry.value[index].keys.first;
                                    onDisplayIconData = getTransactionCategoryIconData(_transactionCategoryFormModel.icon);
                                  });
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GridViewIcon(iconData: entry.value[index].values.first.iconData, isSelected: entry.value[index].keys.first == _transactionCategoryFormModel.icon),
                                    Text(entry.value[index].values.first.name, style: TextStyle(fontSize: 13))
                                  ],
                                ),
                              );
                            }
                          )
                        ],
                      );
                    }).toList(),
                  )
                ),
              )
            ]
          ),
        )
      )
    );
  }
}