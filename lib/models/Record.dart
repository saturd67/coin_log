import 'package:coin_log/form_models/RecordFormModel.dart';
import 'package:coin_log/models/Account.dart';
import 'package:coin_log/models/BaseModel.dart';
import 'package:coin_log/models/TransactionCategory.dart';

enum RecordType {
  expense(name: "Expense"),
  income(name: "Income"),
  transfer(name: "Transfer");

  final String name;

  const RecordType({required this.name});
}

class Record_ implements BaseModel<RecordFormModel>{
  int? identifier;
  DateTime date;
  String? description;
  String type;
  double amount;

  // Foreign keys
  int? transactionCategoryId;
  int? sourceAccountId;
  int? destinationAccountId;

  // Linked objects (optional)
  TransactionCategory? transactionCategory;
  Account? sourceAccount;
  Account? destinationAccount;

  Record_({
    this.identifier,
    required this.date,
    this.description,
    required this.type,
    required this.amount,

    this.transactionCategoryId,
    this.sourceAccountId,
    this.destinationAccountId,
  });

  factory Record_.fromMap(Map<String, dynamic> map) {
    return Record_(
      identifier: map['IDENTIFIER'],
      transactionCategoryId: map['TRANSACTION_CATEGORY_ID'],
      sourceAccountId: map['SOURCE_ACCOUNT_ID'],
      destinationAccountId: map['DESTINATION_ACCOUNT_ID'],
      date: DateTime.parse(map['DATE']),
      description: map['DESCRIPTION'],
      type: map['TYPE'],
      amount: map['AMOUNT']
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic> {
      'TRANSACTION_CATEGORY_ID': transactionCategoryId,
      'SOURCE_ACCOUNT_ID': sourceAccountId,
      'DESTINATION_ACCOUNT_ID': destinationAccountId,
      'DATE': date.toIso8601String(),
      'DESCRIPTION': description,
      'TYPE': type,
      'AMOUNT': amount
    };

    if (identifier != null) {
      map['IDENTIFIER'] = identifier;
    }

    return map;
  }

  @override
  RecordFormModel toFormModel() {
    return RecordFormModel(
      identifier: identifier,
      transactionCategoryId: transactionCategoryId,
      sourceAccountId: sourceAccountId,
      destinationAccountId: destinationAccountId,
      date: date,
      description: description,
      type:type,
      amount: amount
    );
  }
}