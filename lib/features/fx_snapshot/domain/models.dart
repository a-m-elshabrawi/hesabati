class FxSnapshot {
  final DateTime capturedAt;
  final Map<String, double> rates;
  final String note;
  final Map<String, dynamic> meta;

  FxSnapshot({
    required this.capturedAt,
    required this.rates,
    required this.note,
    required this.meta,
  });

  factory FxSnapshot.fromJson(Map<String, dynamic> json) {
    return FxSnapshot(
      capturedAt: DateTime.parse(json['captured_at'] as String),
      rates: Map<String, double>.from(
        (json['rates'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      note: json['note'] as String,
      meta: Map<String, dynamic>.from(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'captured_at': capturedAt.toIso8601String(),
      'rates': rates,
      'note': note,
      'meta': meta,
    };
  }
}

class IsoMeta {
  final String code;
  final int minorUnit;
  final String name;

  IsoMeta({
    required this.code,
    required this.minorUnit,
    required this.name,
  });

  @override
  String toString() => '$name ($code)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IsoMeta &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
