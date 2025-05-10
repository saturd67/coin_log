import 'package:coin_log/objects/TransactionCategory.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/widgets/ThemedTextField.dart';
import 'package:coin_log/widgets/ThemedToast.dart';
import 'package:coin_log/widgets/showConfirmationDialog.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/widgets/GridViewIcon.dart';
import 'package:coin_log/widgets/SwitchButton.dart';
import 'package:coin_log/constants/TransactionCategoryMap.dart';
import 'package:logging/logging.dart';

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
  late TransactionCategory _transactionCategory = TransactionCategory(name: "", icon: "", type: "Expense", sequence: 1);
  IconData? onDisplayIconData;

  @override
  void initState() {
    super.initState();
    _identifier = widget.identifier;

    if (widget.identifier != null) {
      loadTransactionCategory();
    }
  }

  void loadTransactionCategory() async {
    final _transactionCategory = await transactionCategoryService.findById(widget.identifier!);
    setState(() {
      this._transactionCategory = _transactionCategory!;
      onDisplayIconData = coinLogIconMap[this._transactionCategory.icon]!.icon;
    });
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

                if (_transactionCategory.name == "") {
                  ThemedToast.showToast("Invalid Name.");
                  return;
                }

                if (_transactionCategory.type == "") {
                  ThemedToast.showToast("Invalid Type.");
                  return;
                }

                if (_transactionCategory.icon == "") {
                  ThemedToast.showToast("Invalid Icon.");
                  return;
                }

                if (_identifier == null) {
                  TransactionCategory? lastTransactionCategory = await transactionCategoryService.findLastByType("Expend");
                  if (lastTransactionCategory != null) {
                    _transactionCategory.sequence = lastTransactionCategory.sequence + 1;
                  }

                  int? identifier = await transactionCategoryService.add(_transactionCategory);
                  _transactionCategory.identifier = identifier;
                  // print("[TransactionDetail] - Added ${_transactionCategory.toMap()}");
                  _log.info("Added ${_transactionCategory.toMap()}");
                }

                else {
                  int? identifier = await transactionCategoryService.update(_transactionCategory);
                  // print("[TransactionDetail] - Updated ${_transactionCategory.toMap()}");
                  _log.info("Updated ${_transactionCategory.toMap()}");
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
                padding: const EdgeInsets.fromLTRB(2.0, 12.0, 2.0, 6.0),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: onDisplayIconData != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary
                      ),
                      child: Icon(onDisplayIconData ?? Icons.picture_in_picture, color: onDisplayIconData != null ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).iconTheme.color),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: ThemedTextField(
                        placeholder: "Name",
                        maxLenght: 10,
                        value: _transactionCategory.name,
                        onChanged: (value) {
                          _transactionCategory.name = value;
                        },
                      )
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10), 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SwitchButton(
                      labels: ["Expense", "Income"],
                      selectedValue: _transactionCategory.type,
                      onChanged: (value) {
                        _transactionCategory.type = value;
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
                    children: getGroupedIcons().entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                              child: Text(entry.key.value.toString(), style: TextStyle(fontWeight: FontWeight.bold),)
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 2.0,
                              mainAxisSpacing: 2.0,
                              childAspectRatio: 1,
                            ),
                            itemCount: entry.value.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _transactionCategory.icon = entry.value[index].keys.first;
                                    onDisplayIconData = coinLogIconMap[_transactionCategory.icon]!.icon;
                                  });
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GridViewIcon(iconData: entry.value[index].values.first.icon, isSelected: entry.value[index].keys.first == _transactionCategory.icon),
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