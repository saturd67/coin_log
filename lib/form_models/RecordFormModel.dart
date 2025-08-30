import 'package:coin_log/form_models/BaseFormModel.dart';
import 'package:coin_log/form_models/TransactionCategoryFormModel.dart';
import 'package:coin_log/form_models/AccountFormModel.dart';
import 'package:coin_log/models/Record.dart';
import 'package:flutter/cupertino.dart';

class RecordFormModel implements BaseFormModel<Record>{
  int? identifier;
  int? transactionCategoryId;
  int? sourceAccountId;
  int? destinationAccountId;
  DateTime? date;
  String? type;
  double? amount;

  TextEditingController descriptionController = TextEditingController();

  TransactionCategoryFormModel? transactionCategory;
  AccountFormModel? sourceAccount;
  AccountFormModel? destinationAccount;

  RecordFormModel({
    this.identifier,
    this.transactionCategoryId,
    this.sourceAccountId,
    this.destinationAccountId,
    this.date,
    this.type,
    this.amount,

    this.transactionCategory,
    this.sourceAccount,
    this.destinationAccount,

    String? description
  }): descriptionController = TextEditingController(text: description ?? "");

  @override
  void dispose() {
    descriptionController.dispose();
  }

  @override
  Record toModel() {
    if (sourceAccountId == null) {
      throw "Invalid Source Account.";
    }

    if (date == null) {
      throw "Invalid Date.";
    }

    if (type == null) {
      throw "Invalid Type.";
    }

    if (amount == null) {
      throw "Invalid Amount.";
    }

    return Record(
      identifier: identifier,
      transactionCategoryId: transactionCategoryId,
      sourceAccountId: sourceAccountId,
      destinationAccountId: destinationAccountId,
      date: date!,
      type: type!,
      amount: amount!,
      description: descriptionController.text
    );
  }
}