import 'package:coin_log/models/Account.dart';
import 'package:coin_log/models/Record.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/RecordService.dart';

import '../models/AccountLog.dart';

class BalanceManager {

  static final AccountService _accountService = AccountService();
  static final RecordService _recordService = RecordService();

  static Future<void> updateBalanceOnSaveTransactionRecord(Record_ record) async {
    Account account = (await _accountService.findById(record.sourceAccountId!))!;
    double oldBalance = account.balance;
    if (record.type == RecordType.income.name) {
      account.balance += record.amount;
    }

    else if (record.type == RecordType.expense.name) {
      account.balance -= record.amount;
    }

    await _accountService.logUpdateBalance(account.identifier!, record.identifier!, record.date, RecordAction.insert, oldBalance, account.balance);
  }

  static Future<void> updateBalanceOnUpdateTransactionRecord(Record_ newRecord) async {
    Record_ oriRecord = (await _recordService.findById(newRecord.identifier!))!;
    Account oriAccount = (await _accountService.findById(oriRecord.sourceAccountId!))!;
    double oldBalance = oriAccount.balance;
    if (oriRecord.type == RecordType.income.name) {
      oriAccount.balance -= oriRecord.amount;
    }

    else if (oriRecord.type == RecordType.expense.name) {
      oriAccount.balance += oriRecord.amount;
    }

    await _accountService.logUpdateBalance(oriAccount.identifier!, oriRecord.identifier!, oriRecord.date, RecordAction.update, oldBalance, oriAccount.balance);

    Account newAccount = (await _accountService.findById(newRecord.sourceAccountId!))!;
    oldBalance = newAccount.balance;
    if (newRecord.type == RecordType.income.name) {
      newAccount.balance += newRecord.amount;
    }

    else if (newRecord.type == RecordType.expense.name) {
      newAccount.balance -= newRecord.amount;
    }

    await _accountService.logUpdateBalance(newAccount.identifier!, newRecord.identifier!, newRecord.date, RecordAction.update, oldBalance, newAccount.balance);
  }

  static Future<void> updateBalanceOnDeleteTransactionRecord(Record_ record) async {
    Account account = (await _accountService.findById(record.sourceAccountId!))!;
    double oldBalance = account.balance;
    if (record.type == RecordType.income.name) {
      account.balance -= record.amount;
    }

    else if (record.type == RecordType.expense.name) {
      account.balance += record.amount;
    }

    await _accountService.logUpdateBalance(account.identifier!, record.identifier!, record.date, RecordAction.delete, oldBalance, account.balance);
  }

  static Future<void> updateBalanceOnSaveTransferRecord(Record_ record) async {
    Account sourceAccount = (await _accountService.findById(record.sourceAccountId!))!;
    double oldSourceBalance = sourceAccount.balance;
    Account destinationAccount = (await _accountService.findById(record.destinationAccountId!))!;
    double oldDestinationBalance = destinationAccount.balance;

    sourceAccount.balance -= record.amount;
    destinationAccount.balance += record.amount;

    await _accountService.logUpdateBalance(sourceAccount.identifier!, record.identifier!, record.date, RecordAction.insert, oldSourceBalance, sourceAccount.balance);
    await _accountService.logUpdateBalance(destinationAccount.identifier!, record.identifier!, record.date, RecordAction.insert, oldDestinationBalance, destinationAccount.balance);
  }

  static Future<void> updateBalanceOnUpdateTransferRecord(Record_ newRecord) async {
    Record_ oriRecord = (await _recordService.findById(newRecord.identifier!))!;

    Account oriRecordSourceAccount = (await _accountService.findById(oriRecord.sourceAccountId!))!;
    double oldOriRecordSourceBalance = oriRecordSourceAccount.balance;

    Account oriRecordDestinationAccount = (await _accountService.findById(oriRecord.destinationAccountId!))!;
    double oldOriRecordDestinationBalance = oriRecordDestinationAccount.balance;


    oriRecordSourceAccount.balance += oriRecord.amount;
    
    oriRecordDestinationAccount.balance -= oriRecord.amount;


    await _accountService.logUpdateBalance(oriRecordSourceAccount.identifier!, newRecord.identifier!, newRecord.date, RecordAction.update, oldOriRecordSourceBalance, oriRecordSourceAccount.balance);
    await _accountService.logUpdateBalance(oriRecordDestinationAccount.identifier!, newRecord.identifier!, newRecord.date,RecordAction.update, oldOriRecordDestinationBalance, oriRecordDestinationAccount.balance);

    Account newRecordSourceAccount = (await _accountService.findById(newRecord.sourceAccountId!))!;
    double oldNewRecordSourceBalance = newRecordSourceAccount.balance;

    Account newRecordDestinationAccount = (await _accountService.findById(newRecord.destinationAccountId!))!;
    double oldNewRecordDestinationBalance = newRecordDestinationAccount.balance;

    newRecordSourceAccount.balance -= newRecord.amount;
    newRecordDestinationAccount.balance += newRecord.amount;

    await _accountService.logUpdateBalance(newRecordSourceAccount.identifier!, newRecord.identifier!, newRecord.date, RecordAction.update, oldNewRecordSourceBalance, newRecordSourceAccount.balance);
    await _accountService.logUpdateBalance(newRecordDestinationAccount.identifier!, newRecord.identifier!, newRecord.date, RecordAction.update, oldNewRecordDestinationBalance, newRecordDestinationAccount.balance);
  }

  static Future<void> updateBalanceOnDeleteTransferRecord(Record_ record) async {
    Record_ oriRecord = (await _recordService.findById(record.identifier!))!;

    Account sourceAccount = (await _accountService.findById(oriRecord.sourceAccountId!))!;
    double oldSourceBalance = sourceAccount.balance;
    Account destinationAccount = (await _accountService.findById(oriRecord.destinationAccountId!))!;
    double oldDestinationBalance = destinationAccount.balance;

    sourceAccount.balance += oriRecord.amount;
    destinationAccount.balance -= oriRecord.amount;

    await _accountService.logUpdateBalance(sourceAccount.identifier!, oriRecord.identifier!, oriRecord.date, RecordAction.delete, oldSourceBalance, sourceAccount.balance);
    await _accountService.logUpdateBalance(destinationAccount.identifier!, oriRecord.identifier!, oriRecord.date, RecordAction.delete, oldDestinationBalance, destinationAccount.balance);
  }
}