import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/part_scan_entry.dart';
import '../services/parts_service.dart';

/// State management for the QR Code Scanner feature.
///
/// Tracks scan history, resolves part numbers through [PartsService],
/// and persists entries to local storage.
class QrScanProvider extends ChangeNotifier {
  final PartsService _partsService = PartsService();

  List<PartScanEntry> _history = [];
  PartDetails? _currentPartDetails;
  bool _isLookingUp = false;
  String? _error;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Scan history, most-recent first.
  List<PartScanEntry> get history => List.unmodifiable(_history);

  /// Full details for the current selection (after lookup).
  PartDetails? get currentPartDetails => _currentPartDetails;

  /// Whether a part lookup is in progress.
  bool get isLookingUp => _isLookingUp;

  /// Last error message, if any.
  String? get error => _error;

  /// Whether the history has entries.
  bool get hasHistory => _history.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Lookup
  // ---------------------------------------------------------------------------

  /// Look up a scanned value (QR data or manually-entered part number).
  ///
  /// Creates a [PartScanEntry], resolves it via the backend, and stores
  /// the result in [_currentPartDetails].
  Future<void> lookupPart(String scannedValue) async {
    if (scannedValue.trim().isEmpty) return;

    _error = null;
    _isLookingUp = true;
    _currentPartDetails = null;
    notifyListeners();

    // Create a preliminary entry
    final entry = PartScanEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scannedValue: scannedValue.trim(),
      scannedAt: DateTime.now(),
    );

    try {
      final details = await _partsService.getPartDetails(scannedValue.trim());
      _currentPartDetails = details;

      // Update entry with resolved data
      final resolved = entry.copyWith(
        partName: details.partName,
        partNumber: details.partNumber,
        description: details.description,
        imageUrl: details.imageUrl,
        isResolved: true,
      );

      // Prepend to history (most-recent first), dedup by scannedValue
      _history.removeWhere((e) => e.scannedValue == resolved.scannedValue);
      _history.insert(0, resolved);

      // Cap history at 50 entries
      if (_history.length > 50) {
        _history = _history.sublist(0, 50);
      }
    } catch (e) {
      _error = e.toString().replaceFirst('PartsServiceException: ', '');

      // Still add to history as un-resolved
      _history.removeWhere((e) => e.scannedValue == entry.scannedValue);
      _history.insert(0, entry);
    } finally {
      _isLookingUp = false;
      notifyListeners();
      _saveHistory();
    }
  }

  /// Re-lookup details for an existing history entry.
  Future<void> lookupFromHistory(PartScanEntry entry) async {
    await lookupPart(entry.scannedValue);
  }

  // ---------------------------------------------------------------------------
  // History management
  // ---------------------------------------------------------------------------

  /// Remove a single entry from history.
  void removeEntry(String id) {
    _history.removeWhere((e) => e.id == id);
    notifyListeners();
    _saveHistory();
  }

  /// Clear the entire scan history.
  void clearHistory() {
    _history = [];
    _currentPartDetails = null;
    _error = null;
    notifyListeners();
    _saveHistory();
  }

  /// Clear current error.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Load scan history from local storage.
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('qr_scan_history');
      if (raw != null) {
        final list = json.decode(raw) as List;
        _history = list
            .map((e) => PartScanEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load QR scan history: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_history.map((e) => e.toJson()).toList());
      await prefs.setString('qr_scan_history', encoded);
    } catch (e) {
      debugPrint('Failed to save QR scan history: $e');
    }
  }
}
