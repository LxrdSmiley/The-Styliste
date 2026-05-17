// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gala_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GalaEventImpl _$$GalaEventImplFromJson(Map<String, dynamic> json) =>
    _$GalaEventImpl(
      id: json['id'] as String,
      themeTitle: json['theme_title'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: DateTime.parse(json['ends_at'] as String),
      themeDescription: json['theme_description'] as String?,
      styleTags: (json['style_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      status: json['status'] as String? ?? 'upcoming',
      prizePoolLuxe: (json['prize_pool_luxe'] as num?)?.toInt() ?? 10000,
      totalSubmissions: (json['total_submissions'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$GalaEventImplToJson(_$GalaEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'theme_title': instance.themeTitle,
      'starts_at': instance.startsAt.toIso8601String(),
      'ends_at': instance.endsAt.toIso8601String(),
      'theme_description': instance.themeDescription,
      'style_tags': instance.styleTags,
      'status': instance.status,
      'prize_pool_luxe': instance.prizePoolLuxe,
      'total_submissions': instance.totalSubmissions,
    };

_$GalaSubmissionImpl _$$GalaSubmissionImplFromJson(Map<String, dynamic> json) =>
    _$GalaSubmissionImpl(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      playerId: json['player_id'] as String,
      designId: json['design_id'] as String,
      talentId: json['talent_id'] as String?,
      currentScore: (json['current_score'] as num?)?.toDouble() ?? 0.0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      adoreCount: (json['adore_count'] as num?)?.toInt() ?? 0,
      iconicCount: (json['iconic_count'] as num?)?.toInt() ?? 0,
      sovereignCount: (json['sovereign_count'] as num?)?.toInt() ?? 0,
      timelessCount: (json['timeless_count'] as num?)?.toInt() ?? 0,
      submittedAt: json['submitted_at'] == null
          ? null
          : DateTime.parse(json['submitted_at'] as String),
      finalRank: (json['final_rank'] as num?)?.toInt(),
      luxeWon: (json['luxe_won'] as num?)?.toInt() ?? 0,
      isGalaSovereign: json['is_gala_sovereign'] as bool? ?? false,
      designName: json['design_name'] as String?,
      designImageUrl: json['design_image_url'] as String?,
      playerName: json['player_name'] as String?,
      talent: json['talent'] == null
          ? null
          : Talent.fromJson(json['talent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GalaSubmissionImplToJson(
        _$GalaSubmissionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'player_id': instance.playerId,
      'design_id': instance.designId,
      'talent_id': instance.talentId,
      'current_score': instance.currentScore,
      'vote_count': instance.voteCount,
      'adore_count': instance.adoreCount,
      'iconic_count': instance.iconicCount,
      'sovereign_count': instance.sovereignCount,
      'timeless_count': instance.timelessCount,
      'submitted_at': instance.submittedAt?.toIso8601String(),
      'final_rank': instance.finalRank,
      'luxe_won': instance.luxeWon,
      'is_gala_sovereign': instance.isGalaSovereign,
      'design_name': instance.designName,
      'design_image_url': instance.designImageUrl,
      'player_name': instance.playerName,
      'talent': instance.talent?.toJson(),
    };

_$GalaVoteImpl _$$GalaVoteImplFromJson(Map<String, dynamic> json) =>
    _$GalaVoteImpl(
      id: json['id'] as String,
      submissionId: json['submission_id'] as String,
      voterId: json['voter_id'] as String,
      voteTier: json['vote_tier'] as String,
      basePoints: (json['base_points'] as num?)?.toInt() ?? 0,
      talentMultiplier: (json['talent_multiplier'] as num?)?.toDouble() ?? 1.0,
      finalPoints: (json['final_points'] as num?)?.toDouble() ?? 0.0,
      luxeSpent: (json['luxe_spent'] as num?)?.toInt() ?? 0,
      votedAt: json['voted_at'] == null
          ? null
          : DateTime.parse(json['voted_at'] as String),
    );

Map<String, dynamic> _$$GalaVoteImplToJson(_$GalaVoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'submission_id': instance.submissionId,
      'voter_id': instance.voterId,
      'vote_tier': instance.voteTier,
      'base_points': instance.basePoints,
      'talent_multiplier': instance.talentMultiplier,
      'final_points': instance.finalPoints,
      'luxe_spent': instance.luxeSpent,
      'voted_at': instance.votedAt?.toIso8601String(),
    };

_$VoteLimitsImpl _$$VoteLimitsImplFromJson(Map<String, dynamic> json) =>
    _$VoteLimitsImpl(
      playerId: json['player_id'] as String,
      eventId: json['event_id'] as String,
      voteDate: DateTime.parse(json['vote_date'] as String),
      adoreUsed: (json['adore_used'] as num?)?.toInt() ?? 0,
      iconicUsed: (json['iconic_used'] as num?)?.toInt() ?? 0,
      sovereignUsed: (json['sovereign_used'] as num?)?.toInt() ?? 0,
      timelessUsed: (json['timeless_used'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$VoteLimitsImplToJson(_$VoteLimitsImpl instance) =>
    <String, dynamic>{
      'player_id': instance.playerId,
      'event_id': instance.eventId,
      'vote_date': instance.voteDate.toIso8601String(),
      'adore_used': instance.adoreUsed,
      'iconic_used': instance.iconicUsed,
      'sovereign_used': instance.sovereignUsed,
      'timeless_used': instance.timelessUsed,
    };

_$LeaderboardEntryImpl _$$LeaderboardEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$LeaderboardEntryImpl(
      rank: (json['rank'] as num).toInt(),
      submissionId: json['submission_id'] as String,
      playerId: json['player_id'] as String,
      designId: json['design_id'] as String,
      currentScore: (json['current_score'] as num).toDouble(),
      talentId: json['talent_id'] as String?,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      isGalaSovereign: json['is_gala_sovereign'] as bool? ?? false,
      playerName: json['player_name'] as String?,
      designName: json['design_name'] as String?,
      designImageUrl: json['design_image_url'] as String?,
      talentName: json['talent_name'] as String?,
    );

Map<String, dynamic> _$$LeaderboardEntryImplToJson(
        _$LeaderboardEntryImpl instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'submission_id': instance.submissionId,
      'player_id': instance.playerId,
      'design_id': instance.designId,
      'current_score': instance.currentScore,
      'talent_id': instance.talentId,
      'vote_count': instance.voteCount,
      'is_gala_sovereign': instance.isGalaSovereign,
      'player_name': instance.playerName,
      'design_name': instance.designName,
      'design_image_url': instance.designImageUrl,
      'talent_name': instance.talentName,
    };

_$VoteResultImpl _$$VoteResultImplFromJson(Map<String, dynamic> json) =>
    _$VoteResultImpl(
      success: json['success'] as bool,
      finalPoints: (json['final_points'] as num).toDouble(),
      message: json['message'] as String?,
      submissionId: json['submission_id'] as String?,
    );

Map<String, dynamic> _$$VoteResultImplToJson(_$VoteResultImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'final_points': instance.finalPoints,
      'message': instance.message,
      'submission_id': instance.submissionId,
    };
