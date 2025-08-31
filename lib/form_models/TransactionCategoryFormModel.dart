import 'package:coin_log/form_models/BaseFormModel.dart';
import 'package:coin_log/models/TransactionCategory.dart';
import 'package:flutter/cupertino.dart';

class TransactionCategoryFormModel implements BaseFormModel<TransactionCategory>{
  int? identifier;
  String? icon;
  String? type;
  int? sequence;
  bool? isClosed;

  TextEditingController nameController = TextEditingController();

  TransactionCategoryFormModel({
    this.identifier,
    this.icon,
    this.type,
    this.sequence,
    this.isClosed,
    String? name
  }): nameController = TextEditingController(text: name ?? "");

  @override
  void dispose() {
    nameController.dispose();
  }

  @override
  TransactionCategory toModel() {
    if (nameController.text == "") {
      throw "Invalid name.";
    }

    if (icon == null) {
      throw "Invalid icon.";
    }

    if (type == null) {
      throw "Invalid type.";
    }

    if (sequence == null) {
      throw "Invalid sequence.";
    }

    if (isClosed == null) {
      throw "Invalid isClosed.";
    }

    return TransactionCategory(
      identifier: identifier,
      name: nameController.text,
      icon: icon!,
      type: type!,
      sequence: sequence!,
      isClosed: isClosed!
    );
  }


}