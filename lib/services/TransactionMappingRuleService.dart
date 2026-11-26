import 'package:coin_log/models/TransactionMappingRule.dart';

/// Stores the rules that map scanned image text to categories.
///
/// TODO: back this with SQLite (new CL_MAPPING_RULE / CL_MAPPING_RULE_TARGET
/// tables in a schema v5 migration). It is in-memory for now so the UI can be
/// built and tried; rules are lost on restart.
class TransactionMappingRuleService {
  static final TransactionMappingRuleService _instance = TransactionMappingRuleService._internal();

  factory TransactionMappingRuleService() => _instance;

  TransactionMappingRuleService._internal();

  final List<TransactionMappingRule> _transactionMappingRules = [];
  int _nextId = 1;

  Future<List<TransactionMappingRule>> list() async {
    final transactionMappingRules = _transactionMappingRules.map((transactionMappingRule) => transactionMappingRule.copy()).toList()..sort((firstTransactionMappingRule, secondTransactionMappingRule) => firstTransactionMappingRule.sequence.compareTo(secondTransactionMappingRule.sequence));
    return transactionMappingRules;
  }

  Future<TransactionMappingRule?> findById(int identifier) async {
    return _transactionMappingRules.where((transactionMappingRule) => transactionMappingRule.identifier == identifier).firstOrNull?.copy();
  }

  Future<int> save(TransactionMappingRule transactionMappingRule) async {
    final savedTransactionMappingRule = transactionMappingRule.copy()
      ..identifier = _nextId++
      ..sequence = _transactionMappingRules.length;
    _transactionMappingRules.add(savedTransactionMappingRule);
    return savedTransactionMappingRule.identifier!;
  }

  Future<void> update(TransactionMappingRule transactionMappingRule) async {
    final index = _transactionMappingRules.indexWhere((existingTransactionMappingRule) => existingTransactionMappingRule.identifier == transactionMappingRule.identifier);
    if (index >= 0) _transactionMappingRules[index] = transactionMappingRule.copy();
  }

  Future<void> updateSequence(List<TransactionMappingRule> transactionMappingRules) async {
    for (int i = 0; i < transactionMappingRules.length; i++) {
      _transactionMappingRules.where((transactionMappingRule) => transactionMappingRule.identifier == transactionMappingRules[i].identifier).firstOrNull?.sequence = i;
    }
  }

  Future<void> delete(int identifier) async {
    _transactionMappingRules.removeWhere((transactionMappingRule) => transactionMappingRule.identifier == identifier);
  }
}
