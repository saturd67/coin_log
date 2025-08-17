import 'package:coin_log/models/Account.dart';
import 'package:coin_log/models/Record.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/RecordService.dart';

class BalanceManager {

  static final AccountService _accountService = AccountService();
  static final RecordService _recordService = RecordService();

  static Future<void> updateBalanceOnSaveTransactionRecord(Record record) async {
    Account account = (await _accountService.findById(record.sourceAccountId!))!;
    if (record.type == RecordType.income.name) {
      account.balance += record.amount;
    }

    else if (record.type == RecordType.expense.name) {
      account.balance -= record.amount;
    }

    await _accountService.update(account);
  }

  static Future<void> updateBalanceOnUpdateTransactionRecord(Record newRecord) async {
    Record oriRecord = (await _recordService.findById(newRecord.identifier!))!;
    Account oriAccount = (await _accountService.findById(oriRecord.sourceAccountId!))!;

    if (oriRecord.type == RecordType.income.name) {
      oriAccount.balance -= oriRecord.amount;
    }

    else if (oriRecord.type == RecordType.expense.name) {
      oriAccount.balance += oriRecord.amount;
    }

    await _accountService.update(oriAccount);

    Account newAccount = (await _accountService.findById(newRecord.sourceAccountId!))!;

    if (newRecord.type == RecordType.income.name) {
      newAccount.balance += newRecord.amount;
    }

    else if (newRecord.type == RecordType.expense.name) {
      newAccount.balance -= newRecord.amount;
    }

    await _accountService.update(newAccount);
  }

  static Future<void> updateBalanceOnDeleteTransactionRecord(Record record) async {
    Account account = (await _accountService.findById(record.sourceAccountId!))!;

    if (record.type == RecordType.income.name) {
      account.balance -= record.amount;
    }

    else if (record.type == RecordType.expense.name) {
      account.balance += record.amount;
    }

    await _accountService.update(account);
  }

  static Future<void> updateBalanceOnSaveTransferRecord(Record record) async {
    Account sourceAccount = (await _accountService.findById(record.sourceAccountId!))!;
    Account destinationAccount = (await _accountService.findById(record.destinationAccountId!))!;

    sourceAccount.balance -= record.amount;
    destinationAccount.balance += record.amount;

    await _accountService.update(sourceAccount);
    await _accountService.update(destinationAccount);
  }

  static Future<void> updateBalanceOnUpdateTransferRecord(Record newRecord) async {
    Record oriRecord = (await _recordService.findById(newRecord.identifier!))!;
    Account sourceAccount = (await _accountService.findById(newRecord.sourceAccountId!))!;
    Account destinationAccount = (await _accountService.findById(newRecord.destinationAccountId!))!;

    sourceAccount.balance += oriRecord.amount;
    destinationAccount.balance -= oriRecord.amount;

    sourceAccount.balance -= newRecord.amount;
    destinationAccount.balance += newRecord.amount;

    await _accountService.update(sourceAccount);
    await _accountService.update(destinationAccount);
  }

  static Future<void> updateBalanceOnDeleteTransferRecord(Record record) async {
    Account sourceAccount = (await _accountService.findById(record.sourceAccountId!))!;
    Account destinationAccount = (await _accountService.findById(record.destinationAccountId!))!;

    sourceAccount.balance += record.amount;
    destinationAccount.balance -= record.amount;

    await _accountService.update(sourceAccount);
    await _accountService.update(destinationAccount);
  }
}