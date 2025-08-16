import 'package:coin_log/form_models/BaseFormModel.dart';
import 'package:coin_log/models/Account.dart';

class AccountFormModel implements BaseFormModel<Account>{
  int? identifier;
  String? name;
  String? icon;
  int? sequence;
  double? balance;
  bool? isDefault;
  bool? isDeleted;

  AccountFormModel({
    this.identifier,
    this.name,
    this.icon,
    this.sequence,
    this.balance,
    this.isDefault,
    this.isDeleted
  });

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Account toModel() {
    if (name == null) {
      throw Exception("Name could not be null.");
    }

    if (icon == null) {
      throw Exception("Icon could not be null.");
    }

    if (sequence == null) {
      throw Exception("Sequence could not be null.");
    }

    if (isDefault == null) {
      throw Exception("IsDefault could not be null.");
    }

    if (isDeleted == null) {
      throw Exception("IsDeleted could not be null.");
    }

    return Account(
      identifier: identifier,
      name: name!,
      icon: icon!,
      sequence: sequence!,
      balance: balance!,
      isDefault: isDefault!,
      isDeleted: isDeleted!
    );
  }
}