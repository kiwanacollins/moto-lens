import 'package:flutter_test/flutter_test.dart';

import 'package:moto_lens_mobile/models/vehicle/vin_scan_entry.dart';
import 'package:moto_lens_mobile/models/vehicle/vin_decode_result.dart';
import 'package:moto_lens_mobile/models/part_scan_entry.dart';

import '../../helpers/test_helpers.dart';

void main() {
  // ===========================================================================
  // VinScanEntry
  // ===========================================================================

  group('VinScanEntry', () {
    test('fromJson creates entry with all fields', () {
      final json = {
        'vin': 'WBADT63452CK12345',
        'manufacturer': 'BMW',
        'model': '3 Series',
        'year': '2020',
        'scannedAt': '2025-01-15T12:00:00.000',
        'isSynced': true,
      };

      final entry = VinScanEntry.fromJson(json);

      expect(entry.vin, 'WBADT63452CK12345');
      expect(entry.manufacturer, 'BMW');
      expect(entry.model, '3 Series');
      expect(entry.year, '2020');
      expect(entry.isSynced, isTrue);
    });

    test('toJson produces valid JSON round-trip', () {
      final original = TestData.createVinScanEntry();
      final json = original.toJson();
      final restored = VinScanEntry.fromJson(json);

      expect(restored.vin, original.vin);
      expect(restored.manufacturer, original.manufacturer);
      expect(restored.model, original.model);
      expect(restored.year, original.year);
      expect(restored.isSynced, original.isSynced);
    });

    test('displayName concatenates manufacturer, model, year', () {
      final entry = TestData.createVinScanEntry(
        manufacturer: 'BMW',
        model: '3 Series',
        year: '2020',
      );
      expect(entry.displayName, 'BMW 3 Series 2020');
    });

    test('displayName falls back to VIN when no details', () {
      final entry = TestData.createVinScanEntry(
        manufacturer: null,
        model: null,
        year: null,
      );
      expect(entry.displayName, entry.vin);
    });

    test('isSynced defaults to false in fromJson', () {
      final json = {
        'vin': 'TEST12345678901',
        'scannedAt': '2025-01-15T12:00:00.000',
      };
      final entry = VinScanEntry.fromJson(json);
      expect(entry.isSynced, isFalse);
    });

    test('timeAgo returns "Just now" for recent entries', () {
      final entry = VinScanEntry(
        vin: 'TEST12345678901',
        scannedAt: DateTime.now(),
      );
      expect(entry.timeAgo, 'Just now');
    });
  });

  // ===========================================================================
  // VinDecodeResult
  // ===========================================================================

  group('VinDecodeResult', () {
    test('fromJson parses nested vehicle format', () {
      final json = TestData.vinDecodeResultJson();
      final result = VinDecodeResult.fromJson(json);

      expect(result.vin, 'WBADT63452CK12345');
      expect(result.manufacturer, 'BMW');
      expect(result.model, '3 Series');
      expect(result.year, '2020');
      expect(result.bodyStyle, 'Sedan');
      expect(result.engineType, 'B58');
      expect(result.transmission, 'Automatic');
      expect(result.fuelType, 'Gasoline');
    });

    test('toJson round-trip via fromCache', () {
      final original = TestData.createVinDecodeResult();
      final json = original.toJson();
      final restored = VinDecodeResult.fromCache(json);

      expect(restored.vin, original.vin);
      expect(restored.manufacturer, original.manufacturer);
      expect(restored.model, original.model);
      expect(restored.year, original.year);
      expect(restored.bodyStyle, original.bodyStyle);
    });

    test('displayName concatenates available fields', () {
      final result = TestData.createVinDecodeResult(
        manufacturer: 'BMW',
        model: '3 Series',
        year: '2020',
      );
      expect(result.displayName, 'BMW 3 Series 2020');
    });

    test('displayName falls back to VIN', () {
      final result = TestData.createVinDecodeResult(
        manufacturer: null,
        model: null,
        year: null,
      );
      expect(result.displayName, result.vin);
    });

    test('shortName omits year', () {
      final result = TestData.createVinDecodeResult(
        manufacturer: 'BMW',
        model: '3 Series',
      );
      expect(result.shortName, 'BMW 3 Series');
    });

    test('fromJson handles flat format (no nested vehicle key)', () {
      final flatJson = {
        'vin': 'WAUDF48H95K000001',
        'manufacturer': 'Audi',
        'model': 'A4',
        'year': '2023',
      };

      final result = VinDecodeResult.fromJson(flatJson);
      expect(result.vin, 'WAUDF48H95K000001');
      expect(result.manufacturer, 'Audi');
    });

    test('fromJson handles alternative key names (make vs manufacturer)', () {
      final json = {
        'vehicle': {
          'vin': 'WDB1234567F000001',
          'make': 'Mercedes-Benz',
          'model': 'C-Class',
          'year': '2022',
          'bodyClass': 'Sedan',
          'engineModel': 'M264',
          'transmissionStyle': 'Automatic',
          'fuelTypePrimary': 'Gasoline',
          'displacementL': '2.0',
          'engineHP': '255',
          'plantCountry': 'Germany',
        },
      };

      final result = VinDecodeResult.fromJson(json);

      expect(result.manufacturer, 'Mercedes-Benz');
      expect(result.bodyStyle, 'Sedan');
      expect(result.engineType, 'M264');
      expect(result.transmission, 'Automatic');
      expect(result.fuelType, 'Gasoline');
      expect(result.displacement, '2.0');
      expect(result.power, '255');
      expect(result.countryOfOrigin, 'Germany');
    });
  });

  // ===========================================================================
  // PartScanEntry
  // ===========================================================================

  group('PartScanEntry', () {
    test('fromJson creates entry with all fields', () {
      final json = {
        'id': 'part_1',
        'scannedValue': '11-42-7-566-327',
        'scannedAt': '2025-01-15T12:00:00.000',
        'partName': 'Oil Filter',
        'partNumber': '11427566327',
        'description': 'OEM Oil Filter',
        'isResolved': true,
      };

      final entry = PartScanEntry.fromJson(json);

      expect(entry.id, 'part_1');
      expect(entry.scannedValue, '11-42-7-566-327');
      expect(entry.partName, 'Oil Filter');
      expect(entry.isResolved, isTrue);
    });

    test('toJson round-trip', () {
      final original = TestData.createPartScanEntry();
      final json = original.toJson();
      final restored = PartScanEntry.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.scannedValue, original.scannedValue);
      expect(restored.partName, original.partName);
      expect(restored.isResolved, original.isResolved);
    });

    test('displayLabel uses partName when available', () {
      final entry = TestData.createPartScanEntry(partName: 'Oil Filter');
      expect(entry.displayLabel, 'Oil Filter');
    });

    test('displayLabel falls back to scannedValue', () {
      final entry = TestData.createPartScanEntry(partName: null);
      expect(entry.displayLabel, entry.scannedValue);
    });

    test('copyWith creates updated copy preserving unchanged fields', () {
      final original = TestData.createPartScanEntry(isResolved: false);
      final updated = original.copyWith(isResolved: true);

      expect(updated.isResolved, isTrue);
      expect(updated.scannedValue, original.scannedValue);
      expect(updated.id, original.id);
    });

    test('equality is based on id', () {
      final a = TestData.createPartScanEntry(id: 'part_1');
      final b = TestData.createPartScanEntry(id: 'part_1');
      expect(a, equals(b));

      final c = TestData.createPartScanEntry(id: 'part_2');
      expect(a, isNot(equals(c)));
    });

    test('isResolved defaults to false', () {
      final json = {
        'id': 'p1',
        'scannedValue': 'ABC',
        'scannedAt': '2025-01-15T12:00:00.000',
      };
      final entry = PartScanEntry.fromJson(json);
      expect(entry.isResolved, isFalse);
    });
  });

  // ===========================================================================
  // PartDetails
  // ===========================================================================

  group('PartDetails', () {
    test('fromJson parses full part details', () {
      final json = TestData.partDetailsJson();
      final details = PartDetails.fromJson(json);

      expect(details.partId, 'part_123');
      expect(details.partName, 'Oil Filter');
      expect(details.description, isNotNull);
      expect(details.partNumber, '11-42-7-566-327');
      expect(details.symptoms, hasLength(2));
    });

    test('vehicleLabel concatenates year make model', () {
      final details = PartDetails.fromJson(TestData.partDetailsJson());
      expect(details.vehicleLabel, '2020 BMW 3 Series');
    });

    test('vehicleLabel returns empty string when no vehicle', () {
      final details = TestData.createPartDetails();
      expect(details.vehicleLabel, '');
    });

    test('fromJson handles image as string', () {
      final json = {
        'partId': 'p1',
        'partName': 'Test',
        'image': 'https://example.com/image.jpg',
      };
      final details = PartDetails.fromJson(json);
      expect(details.imageUrl, 'https://example.com/image.jpg');
    });

    test('fromJson handles image as map', () {
      final json = {
        'partId': 'p1',
        'partName': 'Test',
        'image': {'url': 'https://example.com/map-image.jpg'},
      };
      final details = PartDetails.fromJson(json);
      expect(details.imageUrl, 'https://example.com/map-image.jpg');
    });

    test('toJson produces valid JSON', () {
      final details = TestData.createPartDetails();
      final json = details.toJson();

      expect(json['partId'], details.partId);
      expect(json['partName'], details.partName);
      expect(json['symptoms'], isA<List<String>>());
    });
  });
}
