import 'package:coin_log/form_models/BaseFormModel.dart';
import 'package:coin_log/models/Account.dart';
import 'package:flutter/cupertino.dart';

class AccountFormModel implements BaseFormModel<Account>{
  int? identifier;
  String? icon;
  int? sequence;
  double? balance;
  bool? isDefault;
  bool? isClosed;

  TextEditingController nameController = TextEditingController();

  AccountFormModel({
    this.identifier,
    this.icon,
    this.sequence,
    this.balance,
    this.isDefault,
    this.isClosed,
    String? name
  }) : nameController = TextEditingController(text: name ?? "");

  @override
  void dispose() {
    nameController.dispose();
  }

  @override
  Account toModel() {
    if (nameController.text == "") {
      throw "Invalid name.";
    }

    if (icon == null) {
      throw "Invalid icon.";
    }

    if (sequence == null) {
      throw "Invalid sequence.";
    }

    if (balance == null) {
      throw "Invalid balance.";
    }

    if (isDefault == null) {
      throw "Invalid isDefault.";
    }

    if (isClosed == null) {
      throw "Invalid isClosed.";
    }

    return Account(
      identifier: identifier,
      name: nameController.text,
      icon: icon!,
      sequence: sequence!,
      balance: balance!,
      isDefault: isDefault!,
      isClosed: isClosed!
    );
  }
}