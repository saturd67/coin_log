import 'package:coin_log/form_models/BudgetFormModel.dart';
import 'package:coin_log/models/BaseModel.dart';
import 'package:coin_log/models/Budget.dart';
import 'package:coin_log/models/TransactionCategory.dart';

import '../form_models/BudgetTransactionFormModel.dart';

class BudgetTransaction implements BaseModel<BudgetTransactionFormModel> {

  int? identifier;
  DateTime date;
  double amount;

  // Foreign keys
  int transactionCategoryId;
  int budgetId;

  // Linked objects (optional)
  TransactionCategory? transactionCategory;
  Budget? budget;

  BudgetTransaction({
    this.identifier,
    required this.transactionCategoryId,
    required this.budgetId,
    required this.date,
    required this.amount,
  });

  factory BudgetTransaction.fromMap(Map<String, dynamic> map) {
    return BudgetTransaction(
      identifier: map['IDENTIFIER'],
      transactionCategoryId: map['TRANSACTION_CATEGORY_ID'],
      budgetId: map['BUDGET_ID'],
      date: DateTime.parse(map['DATE']),
      amount: map['AMOUNT'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'TRANSACTION_CATEGORY_ID': transactionCategoryId,
      'BUDGET_ID': budgetId,
      'DATE': date.toString(),
      'AMOUNT': amount
    };

    if (identifier != null) {
      map['IDENTIFIER'] = identifier;
    }

    return map;
  }

  @override
  BudgetTransactionFormModel toFormModel() {
    return BudgetTransactionFormModel(
      identifier: identifier,
      transactionCategoryId: transactionCategoryId,
      budgetId: budgetId,
      date: date,
      amount: amount
    );
  }
}