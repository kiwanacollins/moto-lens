/// VIN Validation Utility for German Car Medic
///
/// Provides comprehensive VIN (Vehicle Identification Number) validation
/// following ISO 3779 standards. Supports real-time format checking,
/// character validation, and WMI-based manufacturer identification.
class VinValidator {
  VinValidator._();

  /// Valid VIN characters (excludes I, O, Q to avoid confusion with 1, 0, 9)
  static const String validChars = 'ABCDEFGHJKLMNPRSTUVWXYZ0123456789';

  /// VIN length
  static const int vinLength = 17;

  /// Transliteration values for check digit calculation
  static const Map<String, int> _transliterationMap = {
    'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8,
    'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'P': 7, 'R': 9,
    'S': 2, 'T': 3, 'U': 4, 'V': 5, 'W': 6, 'X': 7, 'Y': 8, 'Z': 9,
    '0': 0, '1': 1, '2': 2, '3': 3, '4': 4,
    '5': 5, '6': 6, '7': 7, '8': 8, '9': 9,
  };

  /// Position weights for check digit calculation
  static const List<int> _positionWeights = [
    8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2,
  ];

  /// German manufacturer WMI codes (World Manufacturer Identifier)
  static const Map<String, String> germanManufacturers = {
    'WBA': 'BMW',
    'WBS': 'BMW M',
    'WBY': 'BMW i',
    'WDB': 'Mercedes-Benz',
    'WDC': 'Mercedes-Benz (SUV)',
    'WDD': 'Mercedes-Benz (Sedan)',
    'WDF': 'Mercedes-Benz (Van)',
    'WMW': 'MINI',
    'WAU': 'Audi',
    'WUA': 'Audi (Quattro GmbH)',
    'WVW': 'Volkswagen',
    'WV1': 'Volkswagen Commercial',
    'WV2': 'Volkswagen Bus/Van',
    'WP0': 'Porsche',
    'WP1': 'Porsche (SUV)',
  };

  /// Validate a VIN string and return validation result
  static VinValidationResult validate(String vin) {
    final normalized = vin.toUpperCase().trim();

    // Check length
    if (normalized.isEmpty) {
      return VinValidationResult(
        isValid: false,
        error: 'VIN is required',
        errorType: VinErrorType.empty,
      );
    }

    if (normalized.length < vinLength) {
      return VinValidationResult(
        isValid: false,
        error: 'VIN must be 17 characters (${normalized.length}/$vinLength)',
        errorType: VinErrorType.tooShort,
        partialInfo: _getPartialInfo(normalized),
      );
    }

    if (normalized.length > vinLength) {
      return VinValidationResult(
        isValid: false,
        error: 'VIN must be exactly 17 characters',
        errorType: VinErrorType.tooLong,
      );
    }

    // Check for invalid characters
    for (int i = 0; i < normalized.length; i++) {
      if (!validChars.contains(normalized[i])) {
        String suggestion = '';
        if (normalized[i] == 'I') suggestion = ' (did you mean 1?)';
        if (normalized[i] == 'O') suggestion = ' (did you mean 0?)';
        if (normalized[i] == 'Q') suggestion = ' (did you mean 9?)';

        return VinValidationResult(
          isValid: false,
          error: 'Invalid character "${normalized[i]}" at position ${i + 1}$suggestion',
          errorType: VinErrorType.invalidCharacter,
          errorPosition: i,
        );
      }
    }

    // Verify check digit (position 9, index 8) for North American VINs
    // European VINs don't always use check digits, but we still validate format
    final checkDigitValid = _verifyCheckDigit(normalized);

    // Extract manufacturer info
    final wmi = normalized.substring(0, 3);
    final manufacturer = germanManufacturers[wmi];
    final isGerman = manufacturer != null;

    return VinValidationResult(
      isValid: true,
      normalizedVin: normalized,
      manufacturer: manufacturer,
      isGermanVehicle: isGerman,
      checkDigitValid: checkDigitValid,
      partialInfo: _getPartialInfo(normalized),
    );
  }

  /// Get partial info from a VIN (even incomplete)
  static VinPartialInfo? _getPartialInfo(String vin) {
    if (vin.length < 3) return null;

    final wmi = vin.substring(0, 3);
    final manufacturer = germanManufacturers[wmi];

    String? modelYear;
    if (vin.length >= 10) {
      modelYear = _decodeModelYear(vin[9]);
    }

    return VinPartialInfo(
      wmi: wmi,
      manufacturer: manufacturer,
      countryOfOrigin: _getCountry(vin[0]),
      modelYear: modelYear,
    );
  }

  /// Verify check digit (ISO 3779)
  static bool _verifyCheckDigit(String vin) {
    int sum = 0;
    for (int i = 0; i < 17; i++) {
      final value = _transliterationMap[vin[i]];
      if (value == null) return false;
      sum += value * _positionWeights[i];
    }

    final remainder = sum % 11;
    final checkChar = remainder == 10 ? 'X' : remainder.toString();
    return vin[8] == checkChar;
  }

  /// Decode model year from VIN position 10
  static String? _decodeModelYear(String char) {
    const yearMap = {
      'A': '2010', 'B': '2011', 'C': '2012', 'D': '2013', 'E': '2014',
      'F': '2015', 'G': '2016', 'H': '2017', 'J': '2018', 'K': '2019',
      'L': '2020', 'M': '2021', 'N': '2022', 'P': '2023', 'R': '2024',
      'S': '2025', 'T': '2026', 'V': '2027', 'W': '2028', 'X': '2029',
      'Y': '2030',
      '1': '2001', '2': '2002', '3': '2003', '4': '2004', '5': '2005',
      '6': '2006', '7': '2007', '8': '2008', '9': '2009',
    };
    return yearMap[char];
  }

  /// Get country of origin from first character
  static String? _getCountry(String char) {
    if ('ABCDEFGH'.contains(char)) return 'Africa';
    if ('JKLMNPR'.contains(char)) return 'Asia';
    if ('STUVWXYZ'.contains(char)) return 'Europe';
    if ('12345'.contains(char)) return 'North America';
    if ('6789'.contains(char)) return 'Oceania/South America';
    return null;
  }

  /// Quick check if a VIN looks like it could be valid (for real-time typing)
  static bool isPartiallyValid(String partial) {
    if (partial.isEmpty) return true;
    final normalized = partial.toUpperCase();
    for (int i = 0; i < normalized.length; i++) {
      if (!validChars.contains(normalized[i])) return false;
    }
    return normalized.length <= vinLength;
  }

  /// Sample VINs for testing
  static const List<SampleVin> sampleVins = [
    SampleVin(
      vin: 'WBADT63452CK12345',
      manufacturer: 'BMW',
      description: 'BMW 3 Series',
    ),
    SampleVin(
      vin: 'WDB2030461A123456',
      manufacturer: 'Mercedes-Benz',
      description: 'Mercedes C-Class',
    ),
    SampleVin(
      vin: 'WAUZZZ4G6BN012345',
      manufacturer: 'Audi',
      description: 'Audi A6',
    ),
    SampleVin(
      vin: 'WVWZZZ3CZWE123456',
      manufacturer: 'Volkswagen',
      description: 'VW Golf',
    ),
    SampleVin(
      vin: 'WP0ZZZ99ZTS123456',
      manufacturer: 'Porsche',
      description: 'Porsche 911',
    ),
  ];
}

/// Result of VIN validation
class VinValidationResult {
  final bool isValid;
  final String? error;
  final VinErrorType? errorType;
  final int? errorPosition;
  final String? normalizedVin;
  final String? manufacturer;
  final bool isGermanVehicle;
  final bool checkDigitValid;
  final VinPartialInfo? partialInfo;

  const VinValidationResult({
    required this.isValid,
    this.error,
    this.errorType,
    this.errorPosition,
    this.normalizedVin,
    this.manufacturer,
    this.isGermanVehicle = false,
    this.checkDigitValid = false,
    this.partialInfo,
  });
}

/// Partial info extracted from incomplete VIN
class VinPartialInfo {
  final String wmi;
  final String? manufacturer;
  final String? countryOfOrigin;
  final String? modelYear;

  const VinPartialInfo({
    required this.wmi,
    this.manufacturer,
    this.countryOfOrigin,
    this.modelYear,
  });
}

/// Types of VIN validation errors
enum VinErrorType {
  empty,
  tooShort,
  tooLong,
  invalidCharacter,
  invalidCheckDigit,
}

/// Sample VIN for testing
class SampleVin {
  final String vin;
  final String manufacturer;
  final String description;

  const SampleVin({
    required this.vin,
    required this.manufacturer,
    required this.description,
  });
}
