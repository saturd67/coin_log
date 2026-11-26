import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/main.dart';
import 'package:coin_log/models/Record.dart';
import 'package:coin_log/models/TransactionCategory.dart';
import 'package:coin_log/models/TransactionMappingRule.dart';
import 'package:coin_log/router/RouterUtils.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/services/TransactionMappingRuleService.dart';
import 'package:coin_log/shared_widgets/themed_switch.dart';
import 'package:coin_log/views/settings/mapping_rule_details.dart';
import 'package:flutter/material.dart';

import '../base_view.dart';

class MappingRuleList extends StatefulWidget implements BaseView {
  static const classNameValue = 'MappingRuleList';

  @override
  String get className => classNameValue;

  const MappingRuleList({super.key});

  @override
  State<MappingRuleList> createState() => _MappingRuleListState();
}

class _MappingRuleListState extends State<MappingRuleList> {
  final TransactionMappingRuleService _transactionMappingRuleService = TransactionMappingRuleService();
  final TransactionCategoryService _transactionCategoryService = TransactionCategoryService();

  List<TransactionMappingRule> _transactionMappingRules = [];
  Map<int, TransactionCategory> _transactionCategoriesById = {};

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final (transactionMappingRules, transactionCategories) = await (
      _transactionMappingRuleService.list(),
      _transactionCategoryService.listByIsClosed(null),
    ).wait;

    setState(() {
      _transactionMappingRules = transactionMappingRules;
      _transactionCategoriesById = {for (final transactionCategory in transactionCategories) transactionCategory.identifier!: transactionCategory};
    });
  }

  Future<void> _openDetails({int? identifier}) async {
    final result = await Navigator.of(context).push(RouterUtils.createRoute(MappingRuleDetails(identifier: identifier)));
    if (result == "reload") {
      load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          shadowColor: colorScheme.surface,
          backgroundColor: colorScheme.primary,
          title: const Text("Image Import Rules"),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          tooltip: "Add rule",
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          onPressed: () => _openDetails(),
          child: const Icon(Icons.add),
        ),
        body: Container(
          color: colorScheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: colorScheme.tertiary,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 18, color: colorScheme.onTertiary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Rules turn text read from images into categories. They are checked from top to bottom and the first match wins. Hold and drag to reorder.",
                        style: TextStyle(fontSize: 12, color: colorScheme.onTertiary),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _transactionMappingRules.isEmpty
                    ? const _EmptyRules()
                    : ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        // Bottom space so the floating button never covers the last rule.
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 88),
                        itemCount: _transactionMappingRules.length,
                        onReorderItem: (oldIndex, newIndex) async {
                          setState(() {
                            final transactionMappingRule = _transactionMappingRules.removeAt(oldIndex);
                            _transactionMappingRules.insert(newIndex, transactionMappingRule);
                          });
                          await _transactionMappingRuleService.updateSequence(_transactionMappingRules);
                        },
                        itemBuilder: (context, index) {
                          final transactionMappingRule = _transactionMappingRules[index];
                          return _MappingRuleItem(
                            key: ValueKey(transactionMappingRule.identifier),
                            index: index,
                            transactionMappingRule: transactionMappingRule,
                            transactionCategoriesById: _transactionCategoriesById,
                            onTap: () => _openDetails(identifier: transactionMappingRule.identifier),
                            onEnabledChanged: (value) async {
                              setState(() {
                                transactionMappingRule.isEnabled = value;
                              });
                              await _transactionMappingRuleService.update(transactionMappingRule);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRules extends StatelessWidget {
  const _EmptyRules();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rule, size: 56, color: colorScheme.onTertiary),
            const SizedBox(height: 10),
            Text("No rules yet", style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 4),
            Text(
              "e.g. descriptions containing \"Transfer to\" → Lunch or Dinner by time of day.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colorScheme.onTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MappingRuleItem extends StatelessWidget {
  final int index;
  final TransactionMappingRule transactionMappingRule;
  final Map<int, TransactionCategory> transactionCategoriesById;
  final VoidCallback onTap;
  final ValueChanged<bool> onEnabledChanged;

  const _MappingRuleItem({
    super.key,
    required this.index,
    required this.transactionMappingRule,
    required this.transactionCategoriesById,
    required this.onTap,
    required this.onEnabledChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIncome = transactionMappingRule.type == RecordType.income.name;

    return Card(
      elevation: 1,
      color: colorScheme.secondary,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: transactionMappingRule.isEnabled ? 1 : 0.5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 6, 4, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
                    child: Icon(Icons.drag_indicator, size: 22, color: colorScheme.onTertiary),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          "\"${transactionMappingRule.keyword}\"",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          transactionMappingRule.matchType.name,
                          transactionMappingRule.type,
                        ].join(" · "),
                        style: TextStyle(fontSize: 12, color: isIncome ? colorScheme.success : colorScheme.onTertiary),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final mappingRuleTarget in transactionMappingRule.mappingRuleTargets)
                            _TargetChip(transactionCategory: transactionCategoriesById[mappingRuleTarget.transactionCategoryId], mappingRuleTarget: mappingRuleTarget),
                        ],
                      ),
                    ],
                  ),
                ),
                ThemedSwitch(value: transactionMappingRule.isEnabled, onChanged: onEnabledChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  final TransactionCategory? transactionCategory;
  final MappingRuleTarget mappingRuleTarget;

  const _TargetChip({required this.transactionCategory, required this.mappingRuleTarget});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 2, 8, 2),
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            transactionCategory != null ? getTransactionCategoryIconData(transactionCategory!.icon) : Icons.help_outline,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(transactionCategory?.name ?? "Deleted", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Text(formatTargetTime(mappingRuleTarget), style: TextStyle(fontSize: 11, color: colorScheme.onTertiary)),
        ],
      ),
    );
  }
}

String formatTimeOfDay(TimeOfDay timeOfDay) =>
    "${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}";

String formatTargetTime(MappingRuleTarget mappingRuleTarget) =>
    mappingRuleTarget.isAllDay ? "All day" : "${formatTimeOfDay(mappingRuleTarget.startTimeOfDay!)}–${formatTimeOfDay(mappingRuleTarget.endTimeOfDay!)}";
