import 'package:coin_log/form_models/BaseFormModel.dart';
import 'package:coin_log/models/TransactionCategory.dart';
import 'package:flutter/cupertino.dart';

class TransactionCategoryFormModel implements BaseFormModel<TransactionCategory>{
  int? identifier;
  String? icon;
  String? type;
  int? sequence;
  bool? isDeleted;

  TextEditingController nameController = TextEditingController();

  TransactionCategoryFormModel({
    this.identifier,
    this.icon,
    this.type,
    this.sequence,
    this.isDeleted,
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

    if (isDeleted == null) {
      throw "Invalid isDeleted.";
    }

    return TransactionCategory(
      identifier: identifier,
      name: nameController.text,
      icon: icon!,
      type: type!,
      sequence: sequence!,
      isDeleted: isDeleted!
    );
  }


}