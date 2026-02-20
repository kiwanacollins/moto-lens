class TecDocVehicle {
  final int? manufacturerId;
  final int? vehicleId;
  final int? typeId;
  final int? modelSeriesId;
  final String? modelName;
  final String? engineType;
  final String? fuelType;
  final String? bodyType;
  final int? yearFrom;
  final int? yearTo;
  final String? powerKw;
  final String? powerHp;
  final String? engineDisplacement;
  final Map<String, dynamic> raw;

  TecDocVehicle({
    this.manufacturerId,
    this.vehicleId,
    this.typeId,
    this.modelSeriesId,
    this.modelName,
    this.engineType,
    this.fuelType,
    this.bodyType,
    this.yearFrom,
    this.yearTo,
    this.powerKw,
    this.powerHp,
    this.engineDisplacement,
    this.raw = const {},
  });

  factory TecDocVehicle.fromJson(Map<String, dynamic> json) {
    return TecDocVehicle(
      manufacturerId: json['manuId'] as int? ?? json['manufacturerId'] as int?,
      vehicleId: json['carId'] as int? ?? json['vehicleId'] as int?,
      typeId: json['typeId'] as int?,
      modelSeriesId: json['modelSeriesId'] as int?,
      modelName: json['carName'] as String? ?? json['modelName'] as String?,
      engineType: json['engineType'] as String?,
      fuelType: json['fuelType'] as String?,
      bodyType: json['bodyType'] as String?,
      yearFrom: json['yearFrom'] as int?,
      yearTo: json['yearTo'] as int?,
      powerKw: json['powerKw']?.toString(),
      powerHp: json['powerHp']?.toString(),
      engineDisplacement: json['engineDisplacement']?.toString(),
      raw: json,
    );
  }

  String get displayName {
    final parts = <String>[];
    if (modelName != null) parts.add(modelName!);
    if (engineType != null) parts.add(engineType!);
    if (yearFrom != null)
      parts.add('($yearFrom${yearTo != null ? '-$yearTo' : '+'})');
    return parts.isNotEmpty ? parts.join(' ') : 'Unknown Vehicle';
  }
}

class TecDocArticle {
  final int articleId;
  final String articleNumber;
  final String? articleName;
  final String? description;
  final String? supplierName;
  final int? supplierId;
  final String? imageUrl;
  final List<String> oemNumbers;
  final List<TecDocMedia> images;
  final Map<String, dynamic> raw;

  TecDocArticle({
    required this.articleId,
    required this.articleNumber,
    this.articleName,
    this.description,
    this.supplierName,
    this.supplierId,
    this.imageUrl,
    this.oemNumbers = const [],
    this.images = const [],
    this.raw = const {},
  });

  /// Parse from search-by-article-no response item.
  factory TecDocArticle.fromJson(Map<String, dynamic> json) {
    final oemList = json['oemNumbers'] as List?;
    final imageList = json['images'] as List?;
    return TecDocArticle(
      articleId: json['articleId'] as int? ?? 0,
      articleNumber:
          json['articleNo'] as String? ??
          json['articleNumber'] as String? ??
          '',
      articleName:
          json['articleProductName'] as String? ??
          json['articleName'] as String? ??
          json['genericArticleName'] as String?,
      description:
          json['description'] as String? ?? json['articleText'] as String?,
      supplierName:
          json['supplierName'] as String? ??
          json['dataSupplierName'] as String?,
      supplierId: json['supplierId'] as int? ?? json['dataSupplierId'] as int?,
      imageUrl: json['s3image'] as String?,
      oemNumbers: oemList != null
          ? oemList.map((o) => o.toString()).toList()
          : [],
      images: imageList != null
          ? imageList
                .map((i) => TecDocMedia.fromJson(i as Map<String, dynamic>))
                .toList()
          : [],
      raw: json,
    );
  }
}

class TecDocMedia {
  final String url;
  final String? description;
  final String? type;

  TecDocMedia({required this.url, this.description, this.type});

  factory TecDocMedia.fromJson(Map<String, dynamic> json) {
    return TecDocMedia(
      url: json['url'] as String? ?? json['mediaSource'] as String? ?? '',
      description:
          json['description'] as String? ?? json['fileName'] as String?,
      type: json['mediaType'] as String? ?? json['type'] as String?,
    );
  }
}
