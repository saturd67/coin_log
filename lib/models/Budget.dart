import 'package:coin_log/form_models/BudgetFormModel.dart';
import 'package:coin_log/models/BaseModel.dart';
import 'package:coin_log/models/TransactionCategory.dart';

enum Period {
  weekly(name: "Weekly"),
  monthly(name: "Monthly"),
  yearly(name: "Yearly");

  final String name;

  const Period({required this.name});
}

class Budget implements BaseModel<BudgetFormModel> {

  int? identifier;
  String period;
  double amount;
  bool isClosed;

  // Foreign keys
  int transactionCategoryId;

  // Linked objects (optional)
  TransactionCategory? transactionCategory;

  Budget({
    this.identifier,
    required this.transactionCategoryId,
    required this.period,
    required this.amount,
    required this.isClosed,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      identifier: map['IDENTIFIER'],
      transactionCategoryId: map['TRANSACTION_CATEGORY_ID'],
      period: map['PERIOD'],
      amount: map['AMOUNT'],
      isClosed: map['IS_CLOSED'] == 1 ? true : false
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic> {
      'TRANSACTION_CATEGORY_ID': transactionCategoryId,
      'PERIOD': period,
      'AMOUNT': amount,
      'IS_CLOSED': isClosed ? 1 : 0
    };

    if (identifier != null) {
      map['IDENTIFIER'] = identifier;
    }

    return map;
  }

  @override
  BudgetFormModel toFormModel() {
    return BudgetFormModel(
      identifier: identifier,
      transactionCategoryId: transactionCategoryId,
      period: period,
      amount: amount,
      isClosed: isClosed
    );
  }
}