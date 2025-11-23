import 'package:coin_log/models/Account.dart';
import 'package:coin_log/models/BaseModel.dart';
import 'package:coin_log/models/Record.dart';

enum RecordAction {
  insert,
  update,
  delete;
}

class AccountLog implements BaseModel {
  int? identifier;
  DateTime recordDate;
  String recordAction; // 'insert', 'update', 'delete'
  double oldBalance;
  double newBalance;
  DateTime createdOn;

  // Foreign keys
  int accountId;
  int recordId;

  // Linked objects (optional)
  Account? account;
  Record_? record;

  AccountLog({
    this.identifier,
    required this.recordDate,
    required this.recordAction,
    required this.oldBalance,
    required this.newBalance,
    required this.createdOn,
    required this.accountId,
    required this.recordId,
  });

  factory AccountLog.fromMap(Map<String, dynamic> map) {
    return AccountLog(
      identifier: map['IDENTIFIER'],
      accountId: map['ACCOUNT_ID'],
      recordId: map['RECORD_ID'],
      recordDate: DateTime.parse(map['RECORD_DATE']),
      recordAction: map['RECORD_ACTION'],
      oldBalance: map['OLD_BALANCE'],
      newBalance: map['NEW_BALANCE'],
      createdOn: DateTime.parse(map['CREATED_ON'])
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'ACCOUNT_ID': accountId,
      'RECORD_ID': recordId,
      'RECORD_DATE': recordDate,
      'RECORD_ACTION': recordAction,
      'OLD_BALANCE': oldBalance,
      'NEW_BALANCE': newBalance,
      'CREATED_ON': createdOn.toIso8601String(),
    };

    if (identifier != null) {
      map['IDENTIFIER'] = identifier;
    }

    return map;
  }

  @override
  toFormModel() {
    throw UnimplementedError();
  }
}
