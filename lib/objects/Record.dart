import 'package:coin_log/objects/Account.dart';
import 'package:coin_log/objects/TransactionCategory.dart';

class Record {
  int? identifier;
  int transactionCategoryId;
  int accountId;
  DateTime date;
  String? description;
  String type;
  double amount;

  TransactionCategory? transactionCategory;
  Account? account;

  Record({
    this.identifier,
    required this.transactionCategoryId,
    required this.accountId,
    required this.date,
    this.description,
    required this.type,
    required this.amount
  });

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      identifier: map['IDENTIFIER'],
      transactionCategoryId: map['TRANSACTION_CATEGORY_ID'],
      accountId: map['ACCOUNT_ID'],
      date: DateTime.parse(map['DATE']),
      description: map['DESCRIPTION'],
      type: map['TYPE'],
      amount: map['AMOUNT']
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic> {
      'TRANSACTION_CATEGORY_ID': transactionCategoryId,
      'ACCOUNT_ID': accountId,
      'DATE': date.toString(),
      'DESCRIPTION': description,
      'TYPE': type,
      'AMOUNT': amount
    };

    if (identifier != null) {
      map['IDENTIFIER'] = identifier;
    }

    return map;
  }
}