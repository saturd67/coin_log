import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/main.dart';
import 'package:coin_log/models/Record.dart';
import 'package:coin_log/models/TransactionCategory.dart';
import 'package:coin_log/models/TransactionMappingRule.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/services/TransactionMappingRuleService.dart';
import 'package:coin_log/shared_widgets/grid_view_icon.dart';
import 'package:coin_log/shared_widgets/showConfirmationDialog.dart';
import 'package:coin_log/shared_widgets/switch_button.dart';
import 'package:coin_log/shared_widgets/themed_text_field.dart';
import 'package:coin_log/shared_widgets/themed_toast.dart';
import 'package:coin_log/views/settings/mapping_rule_list.dart';
import 'package:flutter/material.dart';

import '../base_view.dart';

class MappingRuleDetails extends StatefulWidget implements BaseView {
  static const classNameValue = 'MappingRuleDetails';

  @override
  String get className => classNameValue;

  final int? identifier;

  const MappingRuleDetails({super.key, this.identifier});

  @override
  State<MappingRuleDetails> createState() => _MappingRuleDetailsState();
}

class _MappingRuleDetailsState extends State<MappingRuleDetails> {
  final TransactionMappingRuleService _transactionMappingRuleService = TransactionMappingRuleService();
  final TransactionCategoryService _transactionCategoryService = TransactionCategoryService();

  TransactionMappingRule _transactionMappingRule = TransactionMappingRule(keyword: "", type: RecordType.expense.name);
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _testController = TextEditingController();

  List<TransactionCategory> _transactionCategories = [];

  @override
  void initState() {
    super.initState();
    _keywordController.addListener(() => setState(() {}));
    _testController.addListener(() => setState(() {}));
    load();
  }

  Future<void> load() async {
    final transactionCategories = await _transactionCategoryService.listByIsClosed(false);
    final existingTransactionMappingRule = widget.identifier == null ? null : await _transactionMappingRuleService.findById(widget.identifier!);

    setState(() {
      _transactionCategories = transactionCategories;
      if (existingTransactionMappingRule != null) {
        _transactionMappingRule = existingTransactionMappingRule;
        _keywordController.text = _transactionMappingRule.keyword;
      }
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _testController.dispose();
    super.dispose();
  }

  List<TransactionCategory> get _transactionCategoriesOfType => _transactionCategories.where((transactionCategory) => transactionCategory.type == _transactionMappingRule.type).toList();

  TransactionCategory? _findTransactionCategory(int transactionCategoryId) => _transactionCategories.where((transactionCategory) => transactionCategory.identifier == transactionCategoryId).firstOrNull;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    _transactionMappingRule.keyword = _keywordController.text.trim();

    if (_transactionMappingRule.keyword.isEmpty) {
      ThemedToast.showToast("Keyword is required.");
      return;
    }

    if (_transactionMappingRule.mappingRuleTargets.isEmpty) {
      ThemedToast.showToast("Add at least one category.");
      return;
    }

    if (widget.identifier == null) {
      await _transactionMappingRuleService.save(_transactionMappingRule);
    } else {
      await _transactionMappingRuleService.update(_transactionMappingRule);
    }

    if (!mounted) return;
    Navigator.of(context).pop("reload");
  }

  void _delete() {
    showConfirmationDialog(
      context,
      "Are you sure you want to delete?",
      () async {
        await _transactionMappingRuleService.delete(widget.identifier!);
        if (mounted) Navigator.of(context).pop("reload");
      },
      () {},
    );
  }

  void _changeType(String type) {
    if (type == _transactionMappingRule.type) return;
    setState(() {
      _transactionMappingRule.type = type;
      // Categories are type specific, so existing targets no longer apply.
      _transactionMappingRule.mappingRuleTargets.clear();
    });
  }

  Future<void> _addCategory() async {
    final usedTransactionCategoryIds = _transactionMappingRule.mappingRuleTargets.map((mappingRuleTarget) => mappingRuleTarget.transactionCategoryId).toSet();
    final availableTransactionCategories = _transactionCategoriesOfType.where((transactionCategory) => !usedTransactionCategoryIds.contains(transactionCategory.identifier)).toList();

    if (availableTransactionCategories.isEmpty) {
      ThemedToast.showToast("All ${_transactionMappingRule.type.toLowerCase()} categories are already added.");
      return;
    }

    final selectedTransactionCategory = await showModalBottomSheet<TransactionCategory>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Column(
              children: [
                Text("Select Category", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.1, mainAxisSpacing: 8),
                    itemCount: availableTransactionCategories.length,
                    itemBuilder: (context, index) {
                      final transactionCategory = availableTransactionCategories[index];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pop(transactionCategory),
                        child: Column(
                          children: [
                            GridViewIcon(iconData: getTransactionCategoryIconData(transactionCategory.icon)),
                            Text(transactionCategory.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (selectedTransactionCategory != null) {
      setState(() {
        _transactionMappingRule.mappingRuleTargets.add(MappingRuleTarget(transactionCategoryId: selectedTransactionCategory.identifier!));
      });
    }
  }

  Future<TimeOfDay?> _pickTime(String helpText, TimeOfDay initialTimeOfDay) {
    return showTimePicker(
      context: context,
      helpText: helpText,
      initialTime: initialTimeOfDay,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).colorScheme.primary,
            onPrimary: Theme.of(context).colorScheme.onPrimary,
            surface: Theme.of(context).colorScheme.secondary,
            onSurface: Theme.of(context).textTheme.bodyMedium!.color!,
          ),
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      ),
    );
  }

  Future<void> _editTime(MappingRuleTarget mappingRuleTarget) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.all_inclusive, color: Theme.of(context).colorScheme.primary),
              title: Text("All day", style: Theme.of(context).textTheme.bodyMedium),
              trailing: mappingRuleTarget.isAllDay ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () => Navigator.of(context).pop("allDay"),
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: Theme.of(context).colorScheme.primary),
              title: Text("Set time range…", style: Theme.of(context).textTheme.bodyMedium),
              subtitle: mappingRuleTarget.isAllDay ? null : Text(formatTargetTime(mappingRuleTarget)),
              onTap: () => Navigator.of(context).pop("range"),
            ),
          ],
        ),
      ),
    );

    if (choice == "allDay") {
      setState(() {
        mappingRuleTarget.startTimeOfDay = null;
        mappingRuleTarget.endTimeOfDay = null;
      });
    } else if (choice == "range") {
      final startTimeOfDay = await _pickTime("From", mappingRuleTarget.startTimeOfDay ?? const TimeOfDay(hour: 0, minute: 0));
      if (startTimeOfDay == null) return;
      final endTimeOfDay = await _pickTime("To", mappingRuleTarget.endTimeOfDay ?? const TimeOfDay(hour: 23, minute: 59));
      if (endTimeOfDay == null) return;

      setState(() {
        mappingRuleTarget.startTimeOfDay = startTimeOfDay;
        mappingRuleTarget.endTimeOfDay = endTimeOfDay;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Derived state for hints
  // ---------------------------------------------------------------------------

  /// Indexes of targets that can never be chosen because an earlier target
  /// already covers every minute of their range.
  Set<int> get _unreachableTargetIndexes {
    final unreachableTargetIndexes = <int>{};
    for (int i = 0; i < _transactionMappingRule.mappingRuleTargets.length; i++) {
      final coveredByEarlier = List.generate(1440, (minute) => _transactionMappingRule.mappingRuleTargets.take(i).any((mappingRuleTarget) => mappingRuleTarget.coversTime(DateTime(2000, 1, 1, minute ~/ 60, minute % 60))));
      final coveredBySelf = List.generate(1440, (minute) => _transactionMappingRule.mappingRuleTargets[i].coversTime(DateTime(2000, 1, 1, minute ~/ 60, minute % 60)));
      final isReachable = Iterable.generate(1440).any((minute) => coveredBySelf[minute] && !coveredByEarlier[minute]);
      if (!isReachable) unreachableTargetIndexes.add(i);
    }
    return unreachableTargetIndexes;
  }

  bool get _coversWholeDay {
    return Iterable.generate(1440).every((minute) => _transactionMappingRule.mappingRuleTargets.any((mappingRuleTarget) => mappingRuleTarget.coversTime(DateTime(2000, 1, 1, minute ~/ 60, minute % 60))));
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  Widget _sectionLabel(String text, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _hint(String text, {Color? color, IconData icon = Icons.info_outline}) {
    final hintColor = color ?? Theme.of(context).colorScheme.onTertiary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: hintColor),
          const SizedBox(width: 4),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: hintColor))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unreachableTargetIndexes = _unreachableTargetIndexes;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          shadowColor: colorScheme.surface,
          backgroundColor: colorScheme.primary,
          title: const Text("Rule Details"),
          actions: [
            IconButton(onPressed: _save, icon: const Icon(Icons.check_box)),
          ],
        ),
        body: Container(
          color: colorScheme.secondary,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ----- Match ------------------------------------------------
                _sectionLabel(
                  "When description",
                  trailing: widget.identifier != null
                      ? IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: _delete,
                          icon: const Icon(Icons.delete, color: Color(0xffff0000)),
                        )
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SwitchButton(
                    labels: MappingMatchType.values.map((mappingMatchType) => mappingMatchType.name).toList(),
                    selectedValue: _transactionMappingRule.matchType.name,
                    onChanged: (value) => setState(() => _transactionMappingRule.matchType = MappingMatchType.fromName(value)),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ThemedTextField(
                    placeholder: "e.g. Transfer to CHEE LOONG SIN",
                    maxLength: 100,
                    controller: _keywordController,
                  ),
                ),
                _hint("Matched against the description read from the image. Not case sensitive."),

                // ----- Try it ----------------------------------------------
                _sectionLabel("Try it"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ThemedTextField(
                    placeholder: "Paste a sample description",
                    controller: _testController,
                  ),
                ),
                if (_testController.text.trim().isNotEmpty)
                  Builder(builder: (context) {
                    final previewTransactionMappingRule = _transactionMappingRule.copy()..keyword = _keywordController.text;
                    final matched = previewTransactionMappingRule.matches(_testController.text);
                    return _hint(
                      matched ? "Matches this rule" : "Does not match",
                      color: matched ? colorScheme.success : colorScheme.danger,
                      icon: matched ? Icons.check_circle_outline : Icons.highlight_off,
                    );
                  }),

                // ----- Then -------------------------------------------------
                _sectionLabel("Then record as"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SwitchButton(
                    labels: [RecordType.expense.name, RecordType.income.name],
                    selectedValue: _transactionMappingRule.type,
                    onChanged: _changeType,
                  ),
                ),
                _hint("Applies to ${_transactionMappingRule.type == RecordType.expense.name ? "negative" : "positive"} amounts only."),

                _sectionLabel(
                  "Category",
                  trailing: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: colorScheme.primary, visualDensity: VisualDensity.compact),
                    onPressed: _addCategory,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add"),
                  ),
                ),
                if (_transactionMappingRule.mappingRuleTargets.isEmpty) _hint("Add one category, or several with time ranges (e.g. Lunch 11:00–15:59, Dinner 16:00–22:59)."),
                for (int i = 0; i < _transactionMappingRule.mappingRuleTargets.length; i++)
                  _TargetRow(
                    transactionCategory: _findTransactionCategory(_transactionMappingRule.mappingRuleTargets[i].transactionCategoryId),
                    mappingRuleTarget: _transactionMappingRule.mappingRuleTargets[i],
                    isUnreachable: unreachableTargetIndexes.contains(i),
                    onTimeTap: () => _editTime(_transactionMappingRule.mappingRuleTargets[i]),
                    onRemove: () => setState(() => _transactionMappingRule.mappingRuleTargets.removeAt(i)),
                  ),
                if (_transactionMappingRule.mappingRuleTargets.length > 1) _hint("Checked from top to bottom; the first time range that contains the transaction time is used."),
                if (_transactionMappingRule.mappingRuleTargets.isNotEmpty && !_coversWholeDay)
                  _hint(
                    "Transactions outside these times will be left for you to pick a category on review.",
                    color: const Color(0xffe67e22),
                    icon: Icons.warning_amber_rounded,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  final TransactionCategory? transactionCategory;
  final MappingRuleTarget mappingRuleTarget;
  final bool isUnreachable;
  final VoidCallback onTimeTap;
  final VoidCallback onRemove;

  const _TargetRow({
    required this.transactionCategory,
    required this.mappingRuleTarget,
    required this.isUnreachable,
    required this.onTimeTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GridViewIcon(
                iconData: transactionCategory != null ? getTransactionCategoryIconData(transactionCategory!.icon) : Icons.help_outline,
                isSelected: true,
                containerSize: 38,
                iconSize: 22,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(transactionCategory?.name ?? "Deleted category")),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).textTheme.bodyMedium!.color,
                  side: BorderSide(color: colorScheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onTimeTap,
                icon: Icon(mappingRuleTarget.isAllDay ? Icons.all_inclusive : Icons.schedule, size: 16, color: colorScheme.primary),
                label: Text(formatTargetTime(mappingRuleTarget), style: const TextStyle(fontSize: 13)),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onRemove,
                icon: Icon(Icons.close, size: 20, color: colorScheme.onTertiary),
              ),
            ],
          ),
          if (isUnreachable)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 2),
              child: Text(
                "Never used: an earlier category already covers this time.",
                style: TextStyle(fontSize: 12, color: colorScheme.danger),
              ),
            ),
        ],
      ),
    );
  }
}
