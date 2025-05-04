import 'package:coin_log/objects/TransactionCategory.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/widgets/ThemedTextField.dart';
import 'package:coin_log/widgets/ThemedToast.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/widgets/GridViewIcon.dart';
import 'package:coin_log/widgets/SwitchButton.dart';
import 'package:coin_log/constants/TransactionCategoryMap.dart';

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
  final TransactionCategoryService transactionCategoryService = TransactionCategoryService();

  late TransactionCategory transactionCategory = TransactionCategory(name: "", icon: "", type: "Expense", sequence: 1);
  IconData? onDisplayIconData;

  @override
  void initState() {
    super.initState();

    if (widget.identifier != null) {
      loadTransactionCategory();
    }
  }

  void loadTransactionCategory() async {
    final transactionCategory = await transactionCategoryService.findById(widget.identifier!);
    setState(() {
      this.transactionCategory = transactionCategory!;
      onDisplayIconData = coinLogIconMap[this.transactionCategory.icon]!.icon;
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

                if (transactionCategory.name == "") {
                  ThemedToast.showToast("Invalid Name.");
                  return;
                }

                if (transactionCategory.type == "") {
                  ThemedToast.showToast("Invalid Type.");
                  return;
                }

                if (transactionCategory.icon == "") {
                  ThemedToast.showToast("Invalid Icon.");
                  return;
                }

                TransactionCategory? lastTransactionCategory = await transactionCategoryService.findLastByType("Expend");
                if (lastTransactionCategory != null) {
                  transactionCategory.sequence = lastTransactionCategory.sequence + 1;
                }

                int? identifier = await transactionCategoryService.add(transactionCategory);
                transactionCategory.identifier = identifier;
                print("[TransactionDetail] - Added ${transactionCategory.toMap()}");
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
                        onChanged: (value) {
                          transactionCategory.name = value;
                        },
                      )
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10), 
                child: SwitchButton(
                  labels: ["Expense", "Income"],
                  selectedValue: transactionCategory.type,
                  onChanged: (value) {
                    transactionCategory.type = value;
                  }
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
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 2.0,
                              childAspectRatio: 1,
                            ),
                            itemCount: entry.value.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    transactionCategory.icon = entry.value[index].keys.first;
                                    onDisplayIconData = coinLogIconMap[transactionCategory.icon]!.icon;
                                  });
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GridViewIcon(iconData: entry.value[index].values.first.icon, isSelected: entry.value[index].keys.first == transactionCategory.icon),
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