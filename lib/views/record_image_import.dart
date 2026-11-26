import 'dart:io';

import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/constants/WeekMap.dart';
import 'package:coin_log/main.dart';
import 'package:coin_log/models/Account.dart';
import 'package:coin_log/models/Record.dart';
import 'package:coin_log/models/ScannedTransaction.dart';
import 'package:coin_log/models/TransactionCategory.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/ImageTransactionService.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/shared_widgets/showConfirmationDialog.dart';
import 'package:coin_log/shared_widgets/themed_toast.dart';
import 'package:coin_log/utils/DateTimeFormatter.dart';
import 'package:coin_log/views/app_frame/record_list.dart';
import 'package:coin_log/views/base_view.dart';
import 'package:coin_log/views/record_details.dart';
import 'package:coin_log/router/RouterUtils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';

enum _ImportStage { picking, processing, review }

class RecordImageImport extends StatefulWidget implements BaseView {
  static const classNameValue = 'RecordImageImport';

  @override
  String get className => classNameValue;

  const RecordImageImport({super.key});

  @override
  State<RecordImageImport> createState() => _RecordImageImportState();
}

class _RecordImageImportState extends State<RecordImageImport> {
  final _log = Logger('RecordImageImport');

  final ImagePicker _imagePicker = ImagePicker();
  final ImageTransactionService _imageTransactionService = ImageTransactionService();
  final TransactionCategoryService _transactionCategoryService = TransactionCategoryService();
  final AccountService _accountService = AccountService();

  static const int _maxImages = 10;

  _ImportStage _importStage = _ImportStage.picking;
  final List<File> _imageFiles = [];
  List<ScannedTransaction> _scannedTransactions = [];

  List<TransactionCategory> _transactionCategories = [];
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    final (transactionCategories, accounts) = await (
      _transactionCategoryService.listByIsClosed(false),
      _accountService.listByIsClosed(false),
    ).wait;

    setState(() {
      _transactionCategories = transactionCategories;
      _accounts = accounts;
    });
  }

  List<TransactionCategory> _transactionCategoriesOfType(String type) {
    return _transactionCategories.where((transactionCategory) => transactionCategory.type == type).toList();
  }

  TransactionCategory? _findTransactionCategory(int? transactionCategoryId) {
    if (transactionCategoryId == null) return null;
    return _transactionCategories.where((transactionCategory) => transactionCategory.identifier == transactionCategoryId).firstOrNull;
  }

  Account? _findAccount(int? accountId) {
    if (accountId == null) return null;
    return _accounts.where((account) => account.identifier == accountId).firstOrNull;
  }

  // ---------------------------------------------------------------------------
  // Image picking
  // ---------------------------------------------------------------------------

  Future<void> _showImageSourceSheet() async {
    if (_imageFiles.length >= _maxImages) {
      ThemedToast.showToast("You can upload up to $_maxImages images at a time.");
      return;
    }

    final imageSource = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera, color: Theme.of(context).colorScheme.primary),
              title: Text("Take Photo", style: Theme.of(context).textTheme.bodyMedium),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
              title: Text("Choose from Gallery", style: Theme.of(context).textTheme.bodyMedium),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (imageSource == null) return;

    try {
      List<XFile> xFiles;
      if (imageSource == ImageSource.camera) {
        final xFile = await _imagePicker.pickImage(source: ImageSource.camera, maxWidth: 2000, imageQuality: 85);
        xFiles = xFile == null ? [] : [xFile];
      } else {
        xFiles = await _imagePicker.pickMultiImage(maxWidth: 2000, imageQuality: 85);
      }

      if (xFiles.isEmpty) return;

      final remaining = _maxImages - _imageFiles.length;
      if (xFiles.length > remaining) {
        ThemedToast.showToast("Only the first $remaining image(s) were added (limit $_maxImages).");
      }

      setState(() {
        _imageFiles.addAll(xFiles.take(remaining).map((xFile) => File(xFile.path)));
      });
    } catch (e) {
      _log.severe("Failed to pick image", e);
      ThemedToast.showToast("Unable to access images. Please check app permissions.");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  void _previewImage(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(10),
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(child: Center(child: Image.file(imageFile))),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Processing
  // ---------------------------------------------------------------------------

  Future<void> _processImages() async {
    setState(() {
      _importStage = _ImportStage.processing;
    });

    try {
      final scannedTransactions = await _imageTransactionService.extractTransactions(List.of(_imageFiles));
      final defaultAccount = _accounts.where((account) => account.isDefault).firstOrNull ?? _accounts.firstOrNull;

      for (final scannedTransaction in scannedTransactions) {
        scannedTransaction.accountId = defaultAccount?.identifier;
        scannedTransaction.transactionCategoryId = _matchTransactionCategory(scannedTransaction)?.identifier;
      }

      if (!mounted) return;

      if (scannedTransactions.isEmpty) {
        ThemedToast.showToast("No transactions were found in the images.");
        setState(() {
          _importStage = _ImportStage.picking;
        });
        return;
      }

      setState(() {
        _scannedTransactions = scannedTransactions;
        _importStage = _ImportStage.review;
      });
    } catch (e) {
      _log.severe("Failed to process images", e);
      if (!mounted) return;
      ThemedToast.showToast("Failed to process images. Please try again.");
      setState(() {
        _importStage = _ImportStage.picking;
      });
    }
  }

  TransactionCategory? _matchTransactionCategory(ScannedTransaction scannedTransaction) {
    final hint = scannedTransaction.categoryHint?.trim().toLowerCase();
    if (hint == null || hint.isEmpty) return null;
    return _transactionCategoriesOfType(scannedTransaction.type).where((transactionCategory) => transactionCategory.name.toLowerCase() == hint).firstOrNull;
  }

  // ---------------------------------------------------------------------------
  // Review
  // ---------------------------------------------------------------------------

  int get _selectedCount => _scannedTransactions.where((scannedTransaction) => scannedTransaction.isSelected).length;

  /// Groups transaction indexes by day (newest first), mirroring the Records list.
  Map<DateTime, List<int>> _groupedByDay() {
    final indexes = List.generate(_scannedTransactions.length, (i) => i)
      ..sort((firstIndex, secondIndex) => _scannedTransactions[secondIndex].date.compareTo(_scannedTransactions[firstIndex].date));

    final transactionIndexesByDay = <DateTime, List<int>>{};
    for (final index in indexes) {
      final dateTime = _scannedTransactions[index].date;
      transactionIndexesByDay.putIfAbsent(DateTime(dateTime.year, dateTime.month, dateTime.day), () => []).add(index);
    }
    return transactionIndexesByDay;
  }

  bool _isComplete(ScannedTransaction scannedTransaction) => scannedTransaction.transactionCategoryId != null && scannedTransaction.accountId != null && scannedTransaction.amount > 0;

  Future<void> _editTransaction(int index) async {
    final scannedTransaction = _scannedTransactions[index];
    final draftRecord = Record_(
      date: scannedTransaction.date,
      type: scannedTransaction.type,
      amount: scannedTransaction.amount,
      description: scannedTransaction.description,
      transactionCategoryId: scannedTransaction.transactionCategoryId,
      sourceAccountId: scannedTransaction.accountId,
    );

    final editedRecord = await Navigator.of(context).push(RouterUtils.createRoute(
      RecordDetails(returnTo: RecordImageImport.classNameValue, draftRecord: draftRecord),
    ));

    if (editedRecord is Record_) {
      setState(() {
        scannedTransaction.type = editedRecord.type;
        scannedTransaction.amount = editedRecord.amount;
        scannedTransaction.date = editedRecord.date;
        scannedTransaction.description = editedRecord.description;
        scannedTransaction.transactionCategoryId = editedRecord.transactionCategoryId;
        scannedTransaction.accountId = editedRecord.sourceAccountId;
      });
    }
  }

  Future<void> _saveSelected() async {
    final selectedScannedTransactions = _scannedTransactions.where((scannedTransaction) => scannedTransaction.isSelected).toList();

    if (selectedScannedTransactions.isEmpty) {
      ThemedToast.showToast("No transactions selected.");
      return;
    }

    final incomplete = selectedScannedTransactions.where((scannedTransaction) => !_isComplete(scannedTransaction)).length;
    if (incomplete > 0) {
      ThemedToast.showToast("$incomplete selected transaction(s) need a category, account or amount.");
      return;
    }

    // TODO: persist each selected transaction via RecordService.saveTransaction
    // and pop with ["reload", <date>] so the record list refreshes.
    ThemedToast.showToast("Saving ${selectedScannedTransactions.length} transaction(s) is not implemented yet.");
  }

  Future<void> _confirmDiscard() async {
    await showConfirmationDialog(
      context,
      "Discard the detected transactions?",
      () {
        if (mounted) Navigator.of(context).pop();
      },
      () {},
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _importStage == _ImportStage.picking,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_importStage == _ImportStage.review) _confirmDiscard();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            shadowColor: Theme.of(context).colorScheme.surface,
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(_importStage == _ImportStage.review ? "Review Transactions" : "Import from Images"),
          ),
          body: Container(
            color: Theme.of(context).colorScheme.secondary,
            child: switch (_importStage) {
              _ImportStage.picking => _buildPickingStage(context),
              _ImportStage.processing => _buildProcessingStage(context),
              _ImportStage.review => _buildReviewStage(context),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPickingStage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: colorScheme.onTertiary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Add photos of receipts or statements. Transactions will be detected automatically.",
                  style: TextStyle(fontSize: 13, color: colorScheme.onTertiary),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Text(
            "${_imageFiles.length} / $_maxImages images",
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
        Expanded(
          child: _imageFiles.isEmpty
              ? _EmptyImagePlaceholder(onTap: _showImageSourceSheet)
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _imageFiles.length < _maxImages ? _imageFiles.length + 1 : _imageFiles.length,
                  itemBuilder: (context, index) {
                    if (index == _imageFiles.length) {
                      return _AddImageTile(onTap: _showImageSourceSheet);
                    }
                    return _ImageThumbnail(
                      imageFile: _imageFiles[index],
                      label: "${index + 1}",
                      onTap: () => _previewImage(_imageFiles[index]),
                      onRemove: () => _removeImage(index),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _imageFiles.isEmpty ? null : _processImages,
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: Text(_imageFiles.isEmpty ? "Add images to continue" : "Process ${_imageFiles.length} image(s)"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingStage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 4),
          ),
          const SizedBox(height: 20),
          Text("Analysing ${_imageFiles.length} image(s)...", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text("This may take a moment.", style: TextStyle(fontSize: 13, color: colorScheme.onTertiary)),
        ],
      ),
    );
  }

  Widget _buildReviewStage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allSelected = _selectedCount == _scannedTransactions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
          color: colorScheme.tertiary,
          child: Row(
            children: [
              Checkbox(
                value: allSelected ? true : (_selectedCount == 0 ? false : null),
                tristate: true,
                activeColor: colorScheme.primary,
                onChanged: (_) {
                  setState(() {
                    for (final scannedTransaction in _scannedTransactions) {
                      scannedTransaction.isSelected = !allSelected;
                    }
                  });
                },
              ),
              Expanded(
                child: Text(
                  "${_scannedTransactions.length} found · $_selectedCount selected",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              Text("Tap to edit", style: TextStyle(fontSize: 12, color: colorScheme.onTertiary)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final dayMapEntry in _groupedByDay().entries) ...{
                _ScannedRecordDay(
                  dateTime: dayMapEntry.key,
                  indexes: dayMapEntry.value,
                  scannedTransactions: _scannedTransactions,
                  findTransactionCategory: _findTransactionCategory,
                  findAccount: _findAccount,
                  onTap: _editTransaction,
                  onSelectedChanged: (index, value) {
                    setState(() {
                      _scannedTransactions[index].isSelected = value;
                    });
                  },
                ),
              },
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    setState(() {
                      _scannedTransactions = [];
                      _importStage = _ImportStage.picking;
                    });
                  },
                  icon: const Icon(Icons.photo_library_outlined, size: 20),
                  label: const Text("Images"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _selectedCount == 0 ? null : _saveSelected,
                    icon: const Icon(Icons.check, size: 20),
                    label: Text("Save $_selectedCount transaction(s)"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Picking widgets
// -----------------------------------------------------------------------------

class _EmptyImagePlaceholder extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyImagePlaceholder({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withValues(alpha: 0.4),
            border: Border.all(color: colorScheme.primary, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_photo_alternate_outlined, size: 64, color: colorScheme.primary),
                const SizedBox(height: 10),
                Text("Tap to add images", style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 4),
                Text("Camera or gallery", style: TextStyle(fontSize: 13, color: colorScheme.onTertiary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddImageTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddImageTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.tertiary.withValues(alpha: 0.4),
          border: Border.all(color: colorScheme.primary, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: colorScheme.primary),
            const SizedBox(height: 4),
            Text("Add", style: TextStyle(fontSize: 13, color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final File imageFile;
  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _ImageThumbnail({
    required this.imageFile,
    required this.label,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(imageFile, fit: BoxFit.cover, cacheWidth: 300),
          ),
        ),
        Positioned(
          left: 4,
          bottom: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Review widgets
// -----------------------------------------------------------------------------

/// Day card following the Records list pattern ([RecordDay] + [RecordDayHeader]).
class _ScannedRecordDay extends StatelessWidget {
  final DateTime dateTime;
  final List<int> indexes;
  final List<ScannedTransaction> scannedTransactions;
  final TransactionCategory? Function(int?) findTransactionCategory;
  final Account? Function(int?) findAccount;
  final void Function(int index) onTap;
  final void Function(int index, bool value) onSelectedChanged;

  const _ScannedRecordDay({
    required this.dateTime,
    required this.indexes,
    required this.scannedTransactions,
    required this.findTransactionCategory,
    required this.findAccount,
    required this.onTap,
    required this.onSelectedChanged,
  });

  @override
  Widget build(BuildContext context) {
    double sumIncome = 0;
    double sumExpense = 0;
    for (final index in indexes) {
      final scannedTransaction = scannedTransactions[index];
      if (!scannedTransaction.isSelected) continue;
      if (scannedTransaction.type == RecordType.income.name) sumIncome += scannedTransaction.amount;
      if (scannedTransaction.type == RecordType.expense.name) sumExpense += scannedTransaction.amount;
    }

    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.secondary,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(7, 0, 7, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecordDayHeader(
              date: "${DateTimeFormatter.toDayMonth(dateTime)}  ${weekMap[dateTime.weekday.toString()]}",
              sumIncome: sumIncome.toStringAsFixed(2),
              sumExpense: sumExpense.toStringAsFixed(2),
            ),
            const Divider(height: 5),
            for (final index in indexes)
              _ScannedRecordDayBodyItem(
                scannedTransaction: scannedTransactions[index],
                transactionCategory: findTransactionCategory(scannedTransactions[index].transactionCategoryId),
                account: findAccount(scannedTransactions[index].accountId),
                onTap: () => onTap(index),
                onSelectedChanged: (value) => onSelectedChanged(index, value),
              ),
          ],
        ),
      ),
    );
  }
}

/// Row following [TransactionRecordDayBodyItem], with a selection checkbox.
class _ScannedRecordDayBodyItem extends StatelessWidget {
  final ScannedTransaction scannedTransaction;
  final TransactionCategory? transactionCategory;
  final Account? account;
  final VoidCallback onTap;
  final ValueChanged<bool> onSelectedChanged;

  const _ScannedRecordDayBodyItem({
    required this.scannedTransaction,
    required this.transactionCategory,
    required this.account,
    required this.onTap,
    required this.onSelectedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIncome = scannedTransaction.type == RecordType.income.name;
    final hasDescription = scannedTransaction.description != null && scannedTransaction.description!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: scannedTransaction.isSelected ? 1 : 0.5,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Checkbox(
                  value: scannedTransaction.isSelected,
                  activeColor: colorScheme.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  onChanged: (value) => onSelectedChanged(value ?? false),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 10, 0),
                child: Stack(
                  children: [
                    Icon(
                      transactionCategory != null ? getTransactionCategoryIconData(transactionCategory!.icon) : Icons.help_outline,
                      color: transactionCategory != null ? null : colorScheme.danger,
                    ),
                    if (account != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                          child: Icon(getAccountIconData(account!.icon), color: const Color(0xffFFD700), size: 15),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: hasDescription ? 4 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transactionCategory?.name ?? "Select category",
                        style: TextStyle(color: transactionCategory != null ? null : colorScheme.danger),
                      ),
                      if (hasDescription)
                        Text(
                          scannedTransaction.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: colorScheme.onTertiary),
                        ),
                    ],
                  ),
                ),
              ),
              Text(
                "${isIncome ? '+' : '-'}${scannedTransaction.amount.toStringAsFixed(2)}",
                style: TextStyle(color: isIncome ? colorScheme.success : colorScheme.danger),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

