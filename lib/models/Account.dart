import 'package:coin_log/models/BaseModel.dart';

import '../form_models/AccountFormModel.dart';

class Account implements BaseModel<AccountFormModel>{
  int? identifier;
  String name;
  String icon;
  int sequence;
  double balance;
  bool isDefault;
  bool isClosed;

  Account({
    this.identifier,
    required this.name,
    required this.icon,
    required this.sequence,
    required this.balance,
    required this.isDefault,
    required this.isClosed
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      identifier: map['IDENTIFIER'],
      name: map['NAME'],
      icon: map['ICON'],
      sequence: map['SEQUENCE'],
      balance: map['BALANCE'],
      isDefault: map['IS_DEFAULT'] == 1 ? true : false,
      isClosed: map['IS_CLOSED'] == 1 ? true : false
    );
  }

  void addBalance(double amount) {
    balance += amount;
  }

  void deductBalance(double amount) {
    balance -= amount;
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic> {
      'NAME': name,
      'ICON': icon,
      'SEQUENCE': sequence,
      'BALANCE': balance,
      'IS_DEFAULT': isDefault ? 1 : 0,
      'IS_CLOSED': isClosed ? 1 : 0
    };

    if (identifier != null) {
      map['IDENTIFIER'] = identifier;
    }

    return map;
  }

  @override
  AccountFormModel toFormModel() {
    return AccountFormModel(
      identifier: identifier,
      name: name,
      icon: icon,
      sequence: sequence,
      balance: balance,
      isDefault: isDefault,
      isClosed: isClosed
    );
  }
}