// GDD §6.3 — Maison (guild) entity
// 5–20 members; shared treasury, supply-chain, city dominance

import 'package:freezed_annotation/freezed_annotation.dart';

part 'maison.freezed.dart';
part 'maison.g.dart';

enum MaisonRole {
  @JsonValue('founder')
  founder,
  @JsonValue('creative_director')
  creativeDirector,
  @JsonValue('executive_director')
  executiveDirector,
  @JsonValue('brand_director')
  brandDirector,
  @JsonValue('member')
  member,
}

@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Maison with _$Maison {
  const factory Maison({
    required String id,
    required String name,
    required String founderId,
    @Default(0.0) double treasury,
    @Default(<String>[]) List<String> memberIds,
    @Default(<String>[]) List<String> dominatedCities,
    @Default(false) bool isRecruiting,
    DateTime? createdAt,
  }) = _Maison;

  factory Maison.fromJson(Map<String, dynamic> json) => _$MaisonFromJson(json);
}

@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MaisonMember with _$MaisonMember {
  const factory MaisonMember({
    required String maisonId,
    required String playerId,
    required MaisonRole role,
    DateTime? joinedAt,
  }) = _MaisonMember;

  factory MaisonMember.fromJson(Map<String, dynamic> json) =>
      _$MaisonMemberFromJson(json);
}
