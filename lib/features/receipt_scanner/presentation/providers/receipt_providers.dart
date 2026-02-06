// Receipt Scanner Providers - Riverpod state management
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moving_tool_flutter/features/receipt_scanner/data/services/ocr_service.dart';
import 'package:moving_tool_flutter/features/receipt_scanner/domain/models/receipt_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'receipt_providers.g.dart';

/// Current scanned image file
@riverpod
class ScannedImage extends _$ScannedImage {
  @override
  File? build() => null;

  void setImage(File? file) => state = file;
  void clear() => state = null;
}

/// OCR processing state
@riverpod
class ReceiptScan extends _$ReceiptScan {
  @override
  Future<ReceiptData?> build() async => null;

  /// Scan a receipt image
  Future<void> scanImage(File imageFile) async {
    state = const AsyncValue.loading();

    try {
      final receiptData = await OcrService.instance.scanReceipt(imageFile);
      state = AsyncValue.data(receiptData);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Clear scan result
  void clear() {
    state = const AsyncValue.data(null);
  }

  /// Update parsed data manually
  void updateData(ReceiptData data) {
    state = AsyncValue.data(data);
  }
}

/// Image picker helper
@riverpod
ImagePicker imagePicker(Ref ref) {
  return ImagePicker();
}

/// Processed receipts history (in-memory for now)
@riverpod
class ReceiptHistory extends _$ReceiptHistory {
  @override
  List<ReceiptData> build() => [];

  void add(ReceiptData receipt) {
    state = [...state, receipt];
  }

  void remove(int index) {
    final newList = [...state];
    newList.removeAt(index);
    state = newList;
  }

  void clear() => state = [];
}
