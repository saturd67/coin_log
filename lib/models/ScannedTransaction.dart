import 'package:coin_log/models/Record.dart';

/// A transaction detected from an uploaded image by the image-processing backend.
///
/// This is a draft: it is only turned into a [Record_] once the user has
/// reviewed it and assigned a local category and account.
class ScannedTransaction {
  /// [RecordType.expense.name] or [RecordType.income.name].
  String type;
  double amount;
  DateTime date;
  String? description;

  /// Category name suggested by the backend, matched against local categories.
  String? categoryHint;

  /// Index of the uploaded image this transaction was detected in.
  int? sourceImageIndex;

  // Local, user-editable state (not part of the API payload)
  int? transactionCategoryId;
  int? accountId;
  bool isSelected;

  ScannedTransaction({
    required this.type,
    required this.amount,
    required this.date,
    this.description,
    this.categoryHint,
    this.sourceImageIndex,
    this.transactionCategoryId,
    this.accountId,
    this.isSelected = true,
  });

  factory ScannedTransaction.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] as String?)?.toLowerCase();
    return ScannedTransaction(
      type: rawType == 'income' ? RecordType.income.name : RecordType.expense.name,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      description: json['description'],
      categoryHint: json['category'],
      sourceImageIndex: json['image_index'],
    );
  }
}
