import 'package:coin_log/form_models/BaseFormModel.dart';
import 'package:coin_log/models/Budget.dart';
import 'package:coin_log/models/TransactionCategory.dart';
import 'package:flutter/cupertino.dart';

class BudgetFormModel implements BaseFormModel<Budget> {

  int? identifier;
  String? period;

  int? transactionCategoryId;

  TransactionCategory? transactionCategory;

  TextEditingController amountController = TextEditingController();

  BudgetFormModel({
    this.identifier,
    this.period,
    this.transactionCategoryId,
    this.transactionCategory,
    double? amount
  }) : amountController = TextEditingController(text: amount?.toStringAsFixed(2) );

  @override
  void dispose() {
    amountController.dispose();
  }

  @override
  Budget toModel() {
    if (period == null) {
      throw "Invalid period.";
    }

    if (amountController.text == "") {
      throw "Invalid amount.";
    }

    if (transactionCategoryId == null) {
      throw "Invalid transaction category id.";
    }

    return Budget(
      identifier: identifier,
      transactionCategoryId: transactionCategoryId!,
      period: period!,
      amount: double.parse(amountController.text)
    );
  }

}