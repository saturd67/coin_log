import 'package:coin_log/models/Record.dart';
import 'package:flutter/material.dart';

/// How a rule's keyword is compared against the scanned text.
enum MappingMatchType {
  contains(name: "Contains"),
  startsWith(name: "Starts with"),
  exact(name: "Exact");

  final String name;

  const MappingMatchType({required this.name});

  static MappingMatchType fromName(String name) => values.firstWhere((mappingMatchType) => mappingMatchType.name == name, orElse: () => contains);
}

/// A category a rule can resolve to, optionally limited to a time of day.
///
/// A rule with several targets picks the first one whose time range contains
/// the transaction time, e.g. Lunch 11:00–15:59, Dinner 16:00–22:59.
/// A target without a range matches any time.
class MappingRuleTarget {
  int transactionCategoryId;
  TimeOfDay? startTimeOfDay;
  TimeOfDay? endTimeOfDay;

  MappingRuleTarget({
    required this.transactionCategoryId,
    this.startTimeOfDay,
    this.endTimeOfDay,
  });

  bool get isAllDay => startTimeOfDay == null || endTimeOfDay == null;

  bool coversTime(DateTime dateTime) {
    if (isAllDay) return true;

    final minutes = dateTime.hour * 60 + dateTime.minute;
    final start = startTimeOfDay!.hour * 60 + startTimeOfDay!.minute;
    final end = endTimeOfDay!.hour * 60 + endTimeOfDay!.minute;

    // Ranges such as 22:00–02:00 wrap past midnight.
    return start <= end ? minutes >= start && minutes <= end : minutes >= start || minutes <= end;
  }

  MappingRuleTarget copy() {
    return MappingRuleTarget(transactionCategoryId: transactionCategoryId, startTimeOfDay: startTimeOfDay, endTimeOfDay: endTimeOfDay);
  }
}

/// Maps text returned by the image-processing backend to a local category.
class TransactionMappingRule {
  int? identifier;
  String keyword;
  MappingMatchType matchType;

  /// [RecordType.expense.name] or [RecordType.income.name]. The rule only
  /// applies to scanned transactions of this type (derived from amount sign).
  String type;

  List<MappingRuleTarget> mappingRuleTargets;
  int sequence;
  bool isEnabled;

  TransactionMappingRule({
    this.identifier,
    required this.keyword,
    this.matchType = MappingMatchType.contains,
    required this.type,
    List<MappingRuleTarget>? mappingRuleTargets,
    this.sequence = 0,
    this.isEnabled = true,
  }) : mappingRuleTargets = mappingRuleTargets ?? [];

  bool matches(String? text) {
    if (text == null) return false;

    final value = text.trim().toLowerCase();
    final pattern = keyword.trim().toLowerCase();
    if (pattern.isEmpty) return false;

    return switch (matchType) {
      MappingMatchType.contains => value.contains(pattern),
      MappingMatchType.startsWith => value.startsWith(pattern),
      MappingMatchType.exact => value == pattern,
    };
  }

  /// The target whose time range covers [dateTime], or null if none does.
  MappingRuleTarget? resolveTarget(DateTime dateTime) {
    for (final mappingRuleTarget in mappingRuleTargets) {
      if (mappingRuleTarget.coversTime(dateTime)) return mappingRuleTarget;
    }
    return null;
  }

  TransactionMappingRule copy() {
    return TransactionMappingRule(
      identifier: identifier,
      keyword: keyword,
      matchType: matchType,
      type: type,
      mappingRuleTargets: mappingRuleTargets.map((mappingRuleTarget) => mappingRuleTarget.copy()).toList(),
      sequence: sequence,
      isEnabled: isEnabled,
    );
  }
}
