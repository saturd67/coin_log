import 'package:coin_log/form_models/BaseFormModel.dart';
import 'package:coin_log/form_models/TransactionCategoryFormModel.dart';
import 'package:coin_log/form_models/AccountFormModel.dart';

class RecordFormModel {
  int? identifier;
  int? transactionCategoryId;
  int? sourceAccountId;
  int? destinationAccountId;
  DateTime? date;
  String? description;
  String? type;
  double? amount;

  TransactionCategoryFormModel? transactionCategory;
  AccountFormModel? sourceAccount;
  AccountFormModel? destinationAccount;

  RecordFormModel({
    this.identifier,
    this.transactionCategoryId,
    this.sourceAccountId,
    this.destinationAccountId,
    required this.date,
    this.description,
    required this.type,
    required this.amount
  });
}