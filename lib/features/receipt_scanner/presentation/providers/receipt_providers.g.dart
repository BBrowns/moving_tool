// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Current scanned image file

@ProviderFor(ScannedImage)
final scannedImageProvider = ScannedImageProvider._();

/// Current scanned image file
final class ScannedImageProvider
    extends $NotifierProvider<ScannedImage, File?> {
  /// Current scanned image file
  ScannedImageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scannedImageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scannedImageHash();

  @$internal
  @override
  ScannedImage create() => ScannedImage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(File? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<File?>(value),
    );
  }
}

String _$scannedImageHash() => r'b5c167868ce472280ff5b69ff4b63b314724a07b';

/// Current scanned image file

abstract class _$ScannedImage extends $Notifier<File?> {
  File? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<File?, File?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<File?, File?>,
              File?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// OCR processing state

@ProviderFor(ReceiptScan)
final receiptScanProvider = ReceiptScanProvider._();

/// OCR processing state
final class ReceiptScanProvider
    extends $AsyncNotifierProvider<ReceiptScan, ReceiptData?> {
  /// OCR processing state
  ReceiptScanProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receiptScanProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receiptScanHash();

  @$internal
  @override
  ReceiptScan create() => ReceiptScan();
}

String _$receiptScanHash() => r'1d2c4f1b212634527e12e15351c6ac68beb3b3f7';

/// OCR processing state

abstract class _$ReceiptScan extends $AsyncNotifier<ReceiptData?> {
  FutureOr<ReceiptData?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ReceiptData?>, ReceiptData?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ReceiptData?>, ReceiptData?>,
              AsyncValue<ReceiptData?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Image picker helper

@ProviderFor(imagePicker)
final imagePickerProvider = ImagePickerProvider._();

/// Image picker helper

final class ImagePickerProvider
    extends $FunctionalProvider<ImagePicker, ImagePicker, ImagePicker>
    with $Provider<ImagePicker> {
  /// Image picker helper
  ImagePickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imagePickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imagePickerHash();

  @$internal
  @override
  $ProviderElement<ImagePicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImagePicker create(Ref ref) {
    return imagePicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImagePicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImagePicker>(value),
    );
  }
}

String _$imagePickerHash() => r'7877699a862be48e962306635347623c45e91971';

/// Processed receipts history (in-memory for now)

@ProviderFor(ReceiptHistory)
final receiptHistoryProvider = ReceiptHistoryProvider._();

/// Processed receipts history (in-memory for now)
final class ReceiptHistoryProvider
    extends $NotifierProvider<ReceiptHistory, List<ReceiptData>> {
  /// Processed receipts history (in-memory for now)
  ReceiptHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receiptHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receiptHistoryHash();

  @$internal
  @override
  ReceiptHistory create() => ReceiptHistory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ReceiptData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ReceiptData>>(value),
    );
  }
}

String _$receiptHistoryHash() => r'86c0f7e448bf67c3bbb0ca9b9549554a79bacda2';

/// Processed receipts history (in-memory for now)

abstract class _$ReceiptHistory extends $Notifier<List<ReceiptData>> {
  List<ReceiptData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<ReceiptData>, List<ReceiptData>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ReceiptData>, List<ReceiptData>>,
              List<ReceiptData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
