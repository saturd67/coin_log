import 'package:coin_log/objects/Account.dart';
import 'package:coin_log/objects/Record.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/RecordService.dart';

class BalanceManager {

  static final AccountService _accountService = AccountService();
  static final RecordService _recordService = RecordService();

  static Future<void> updateBalanceOnSaveRecord(Record record) async {
    Account account = (await _accountService.findById(record.accountId))!;
    if (record.type == "Income") {
      account.balance += record.amount;
    }

    else if (record.type == "Expense") {
      account.balance -= record.amount;
    }

    await _accountService.update(account);
  }

  static Future<void> updateBalanceOnUpdateRecord(Record newRecord) async {
    Record oriRecord = (await _recordService.findById(newRecord.identifier!))!;
    Account oriAccount = (await _accountService.findById(oriRecord.accountId))!;

    if (oriRecord.type == "Income") {
      oriAccount.balance -= oriRecord.amount;
    }

    else if (oriRecord.type == "Expense") {
      oriAccount.balance += oriRecord.amount;
    }

    await _accountService.update(oriAccount);

    Account newAccount = (await _accountService.findById(newRecord.accountId))!;

    if (newRecord.type == "Income") {
      newAccount.balance += newRecord.amount;
    }

    else if (newRecord.type == "Expense") {
      newAccount.balance -= newRecord.amount;
    }

    await _accountService.update(newAccount);
  }

  static Future<void> updateBalanceOnDeleteRecord(Record record) async {
    Account account = (await _accountService.findById(record.accountId))!;

    if (record.type == "Income") {
      account.balance -= record.amount;
    }

    else if (record.type == "Expense") {
      account.balance += record.amount;
    }

    await _accountService.update(account);
  }
}