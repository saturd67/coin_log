import 'package:coin_log/form_models/BaseFormModel.dart';
import 'package:coin_log/models/BudgetTransaction.dart';
import 'package:flutter/cupertino.dart';

import '../models/Budget.dart';
import '../models/TransactionCategory.dart';

class BudgetTransactionFormModel implements BaseFormModel<BudgetTransaction> {

  int? identifier;
  DateTime? startDate;
  DateTime? endDate;

  // Foreign keys
  int? transactionCategoryId;
  int? budgetId;

  // Linked objects (optional)
  TransactionCategory? transactionCategory;
  Budget? budget;

  TextEditingController amountController = TextEditingController();

  BudgetTransactionFormModel({
    this.identifier,
    this.startDate,
    this.endDate,
    this.transactionCategoryId,
    this.budgetId,
    double? amount
  }) : amountController = TextEditingController(text: amount?.toStringAsFixed(2));

  @override
  void dispose() {
    amountController.dispose();
  }

  @override
  BudgetTransaction toModel() {
    return BudgetTransaction(
      identifier: identifier,
      transactionCategoryId: transactionCategoryId!,
      budgetId: budgetId!,
      startDate: startDate!,
      endDate: endDate!,
      amount: double.parse(amountController.text)
    );
  }

}