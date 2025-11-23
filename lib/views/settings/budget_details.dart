import 'package:coin_log/form_models/BudgetFormModel.dart';
import 'package:coin_log/models/Budget.dart';
import 'package:coin_log/models/Record.dart';
import 'package:coin_log/models/TransactionCategory.dart';
import 'package:coin_log/services/BudgetService.dart';
import 'package:coin_log/shared_widgets/switch_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../../constants/IconMap.dart';
import '../../services/TransactionCategoryService.dart';
import '../../shared_widgets/grid_view_icon.dart';
import '../../shared_widgets/showConfirmationDialog.dart';
import '../../shared_widgets/themed_text_field.dart';
import '../../shared_widgets/themed_toast.dart';
import '../base_view.dart';

class BudgetDetails extends StatefulWidget implements BaseView {
  static const classNameValue = 'BudgetDetails';

  @override
  String get className => classNameValue;

  int? identifer;

  BudgetDetails({
    this.identifer
  });

  @override
  State<BudgetDetails> createState() => _BudgetDetailsState();
}

class _BudgetDetailsState extends State<BudgetDetails> {
  final _log = Logger('BudgetDetails');
  final BudgetService _budgetService = BudgetService();
  final TransactionCategoryService _transactionCategoryService = TransactionCategoryService();

  List<TransactionCategory> _transactionCategories = [];
  BudgetFormModel _budgetFormModel = BudgetFormModel(period: Period.monthly.name, isClosed: false);
  IconData? onDisplayIconData;
  String? onDisplayName;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final transactionCategories = await _transactionCategoryService.listByTypeIsClosed(RecordType.expense.name, false);

    setState(() {
      _transactionCategories = transactionCategories;
    });

    if (widget.identifer != null) {
      final budget = await _budgetService.findById(widget.identifer!);

      if (budget != null) {
        final transactionCategory = await _transactionCategoryService.findById(budget.transactionCategoryId);
        budget.transactionCategory = transactionCategory;
        setState(() {
          _budgetFormModel = budget.toFormModel();
          onDisplayIconData = getTransactionCategoryIconData(budget.transactionCategory!.icon);
          onDisplayName = budget.transactionCategory!.name;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              shadowColor: Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: const Text("Budget Details"),
              actions: [
                IconButton(
                    onPressed: () async {
                      Budget budget;

                      try {
                        budget = _budgetFormModel.toModel();
                      }

                      catch(e) {
                        ThemedToast.showToast(e.toString());
                        return;
                      }

                      if (widget.identifer == null) {
                        int? identifier = await _budgetService.save(budget);
                        budget.identifier = identifier;
                        _log.info("Saved ${budget.toMap()}");
                      }

                      else {
                        int? identifier = await _budgetService.update(budget);
                        _log.info("Updated ${budget.toMap()}");
                      }

                      Navigator.of(context).pop("reload");
                    },
                    icon: const Icon(Icons.check_box)
                )
              ],
            ),
            body: Container(
              color: Theme.of(context).colorScheme.secondary,
              padding: const EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
              child: Column(
                children: [
                  SwitchButton(
                    labels: [Period.monthly.name, Period.yearly.name],
                    selectedValue: _budgetFormModel.period!,
                    onChanged: (value) {
                        _budgetFormModel.period = value;
                    }
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 65,
                          height: 45,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: onDisplayIconData != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary
                          ),
                          child: Icon(onDisplayIconData ?? Icons.picture_in_picture, color: onDisplayIconData != null ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSecondary),
                        ),
                        Expanded(
                            child: Text(onDisplayName ?? "Please Select", style: onDisplayName == null ? TextStyle(color: Theme.of(context).colorScheme.onTertiary) : Theme.of(context).textTheme.bodyMedium,)
                        ),
                      ],
                    ),
                  ),
                  Table(
                    columnWidths: const<int, TableColumnWidth> {
                      0: FixedColumnWidth(80.0),
                      1: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Type: ", style: Theme.of(context).textTheme.bodySmall),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Expense"),
                            ),
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Amount: ", style: Theme.of(context).textTheme.bodySmall),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ThemedTextField(
                                      placeholder: "Amount",
                                      textInputType: TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                      ],
                                      controller: _budgetFormModel.amountController,
                                    ),
                                  ),
                                  if (widget.identifer != null)
                                    IconButton(
                                      onPressed: () async {
                                        showConfirmationDialog(
                                            context,
                                            "Are you sure you want to delete?",
                                                () async {
                                              await _budgetService.delete(widget.identifer!);
                                              Navigator.of(context).pop("reload");
                                            },
                                                () {});
                                      },
                                      icon: Icon(Icons.delete, color: Color(0xffff0000))
                                    )
                                ],
                              ),
                            ),
                          )
                        ]
                      ),
                    ]
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 100,
                          crossAxisSpacing: 2.0,
                          mainAxisSpacing: 2.0,
                          childAspectRatio: 1,
                        ),
                        itemCount: _transactionCategories.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _budgetFormModel.transactionCategoryId = _transactionCategories[index].identifier;
                                onDisplayIconData = getTransactionCategoryIconData(_transactionCategories[index].icon);
                                onDisplayName = _transactionCategories[index].name;
                              });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GridViewIcon(iconData: getTransactionCategoryIconData(_transactionCategories[index].icon), isSelected: _budgetFormModel.transactionCategoryId == _transactionCategories[index].identifier),
                                Text(_transactionCategories[index].name, textAlign: TextAlign.center , style: TextStyle(fontSize: 13))
                              ],
                            ),
                          );
                        }
                      )
                    ),
                  )
                ],
              ),
            )
        )
    );
  }
}