import 'dart:io';

import 'package:coin_log/models/ScannedTransaction.dart';

/// Sends images to the image-processing backend and returns the transactions
/// it detected.
abstract class ImageTransactionService {
  factory ImageTransactionService() => MockImageTransactionService();

  Future<List<ScannedTransaction>> extractTransactions(List<File> imageFiles);
}

/// Temporary stand-in until the REST backend is available.
///
/// TODO: replace with an HTTP implementation that uploads [imageFiles] as
/// multipart/form-data and maps the JSON response via
/// [ScannedTransaction.fromJson].
class MockImageTransactionService implements ImageTransactionService {
  @override
  Future<List<ScannedTransaction>> extractTransactions(List<File> imageFiles) async {
    await Future.delayed(const Duration(seconds: 2));

    final currentDateTime = DateTime.now();
    final sampleMaps = [
      {'type': 'expense', 'amount': 12.50, 'description': 'Nasi lemak & teh tarik', 'category': 'Breakfast'},
      {'type': 'expense', 'amount': 18.90, 'description': 'Chicken rice set', 'category': 'Lunch'},
      {'type': 'expense', 'amount': 45.00, 'description': 'Grocery store', 'category': 'Groceries'},
      {'type': 'income', 'amount': 3500.00, 'description': 'Monthly salary', 'category': 'Salary'},
    ];

    final scannedTransactions = <ScannedTransaction>[];
    for (int i = 0; i < imageFiles.length; i++) {
      final sampleMap = sampleMaps[i % sampleMaps.length];
      scannedTransactions.add(ScannedTransaction.fromJson({
        ...sampleMap,
        'date': currentDateTime.subtract(Duration(days: i)).toIso8601String(),
        'image_index': i,
      }));
    }
    return scannedTransactions;
  }
}
