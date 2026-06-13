import 'package:freezed_annotation/freezed_annotation.dart';

part 'water_entry_model.freezed.dart';
part 'water_entry_model.g.dart';

/// Glass size enum: 0=small(150ml), 1=medium(250ml), 2=standard(300ml), 3=large(500ml), 4=bottle(750ml)
@freezed
class WaterEntry with _$WaterEntry {
  const factory WaterEntry({
    required String id,
    required int amountMl,
    required DateTime timestamp,
    String? note,
    @Default(2) int glassSize,
  }) = _WaterEntry;

  factory WaterEntry.fromJson(Map<String, dynamic> json) =>
      _$WaterEntryFromJson(json);
}
