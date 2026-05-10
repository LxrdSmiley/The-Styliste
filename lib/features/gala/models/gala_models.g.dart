// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gala_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GalaEventImpl _$$GalaEventImplFromJson(Map<String, dynamic> json) =>
    _$GalaEventImpl(
      id: json['id'] as String,
      themeTitle: json['themeTitle'] as String,
      themeDescription: json['themeDescription'] as String?,
      styleTags: (json['styleTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: DateTime.parse(json['endsAt'] as String),
      status: json['status'] as String? ?? 'upcoming',
      prizePoolLuxe: (json['prizePoolLuxe'] as num?)?.toInt() ?? 10000,
      totalSubmissions: (json['totalSubmissions'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$GalaEventImplToJson(_$GalaEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'themeTitle': instance.themeTitle,
      'themeDescription': instance.themeDescription,
      'styleTags': instance.styleTags,
      'startsAt': instance.startsAt.toIso8601String(),
      'endsAt': instance.endsAt.toIso8601String(),
      'status': instance.status,
      'prizePoolLuxe': instance.prizePoolLuxe,
      'totalSubmissions': instance.totalSubmissions,
    };

_$GalaSubmissionImpl _$$GalaSubmissionImplFromJson(Map<String, dynamic> json) =>
    _$GalaSubmissionImpl(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      playerId: json['playerId'] as String,
      designId: json['designId'] as String,
      talentId: json['talentId'] as String?,
      currentScore: (json['currentScore'] as num?)?.toDouble() ?? 0.0,
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
      adoreCount: (json['adoreCount'] as num?)?.toInt() ?? 0,
      iconicCount: (json['iconicCount'] as num?)?.toInt() ?? 0,
      sovereignCount: (json['sovereignCount'] as num?)?.toInt() ?? 0,
      timelessCount: (json['timelessCount'] as num?)?.toInt() ?? 0,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      finalRank: (json['finalRank'] as num?)?.toInt(),
      luxeWon: (json['luxeWon'] as num?)?.toInt() ?? 0,
      isGalaSovereign: json['isGalaSovereign'] as bool? ?? false,
      designName: json['designName'] as String?,
      designImageUrl: json['designImageUrl'] as String?,
      playerName: json['playerName'] as String?,
      talent: json['talent'] == null
          ? null
          : Talent.fromJson(json['talent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GalaSubmissionImplToJson(
        _$GalaSubmissionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'playerId': instance.playerId,
      'designId': instance.designId,
      'talentId': instance.talentId,
      'currentScore': instance.currentScore,
      'voteCount': instance.voteCount,
      'adoreCount': instance.adoreCount,
      'iconicCount': instance.iconicCount,
      'sovereignCount': instance.sovereignCount,
      'timelessCount': instance.timelessCount,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'finalRank': instance.finalRank,
      'luxeWon': instance.luxeWon,
      'isGalaSovereign': instance.isGalaSovereign,
      'designName': instance.designName,
      'designImageUrl': instance.designImageUrl,
      'playerName': instance.playerName,
      'talent': instance.talent,
    };

_$GalaVoteImpl _$$GalaVoteImplFromJson(Map<String, dynamic> json) =>
    _$GalaVoteImpl(
      id: json['id'] as String,
      submissionId: json['submissionId'] as String,
      voterId: json['voterId'] as String,
      voteTier: json['voteTier'] as String,
      basePoints: (json['basePoints'] as num?)?.toInt() ?? 0,
      talentMultiplier: (json['talentMultiplier'] as num?)?.toDouble() ?? 1.0,
      finalPoints: (json['finalPoints'] as num?)?.toDouble() ?? 0.0,
      luxeSpent: (json['luxeSpent'] as num?)?.toInt() ?? 0,
      votedAt: json['votedAt'] == null
          ? null
          : DateTime.parse(json['votedAt'] as String),
    );

Map<String, dynamic> _$$GalaVoteImplToJson(_$GalaVoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'submissionId': instance.submissionId,
      'voterId': instance.voterId,
      'voteTier': instance.voteTier,
      'basePoints': instance.basePoints,
      'talentMultiplier': instance.talentMultiplier,
      'finalPoints': instance.finalPoints,
      'luxeSpent': instance.luxeSpent,
      'votedAt': instance.votedAt?.toIso8601String(),
    };

_$VoteLimitsImpl _$$VoteLimitsImplFromJson(Map<String, dynamic> json) =>
    _$VoteLimitsImpl(
      playerId: json['playerId'] as String,
      eventId: json['eventId'] as String,
      voteDate: DateTime.parse(json['voteDate'] as String),
      adoreUsed: (json['adoreUsed'] as num?)?.toInt() ?? 0,
      iconicUsed: (json['iconicUsed'] as num?)?.toInt() ?? 0,
      sovereignUsed: (json['sovereignUsed'] as num?)?.toInt() ?? 0,
      timelessUsed: (json['timelessUsed'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$VoteLimitsImplToJson(_$VoteLimitsImpl instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'eventId': instance.eventId,
      'voteDate': instance.voteDate.toIso8601String(),
      'adoreUsed': instance.adoreUsed,
      'iconicUsed': instance.iconicUsed,
      'sovereignUsed': instance.sovereignUsed,
      'timelessUsed': instance.timelessUsed,
    };

_$LeaderboardEntryImpl _$$LeaderboardEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$LeaderboardEntryImpl(
      rank: (json['rank'] as num).toInt(),
      submissionId: json['submissionId'] as String,
      playerId: json['playerId'] as String,
      designId: json['designId'] as String,
      talentId: json['talentId'] as String?,
      currentScore: (json['currentScore'] as num).toDouble(),
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
      isGalaSovereign: json['isGalaSovereign'] as bool? ?? false,
      playerName: json['playerName'] as String?,
      designName: json['designName'] as String?,
      designImageUrl: json['designImageUrl'] as String?,
      talentName: json['talentName'] as String?,
    );

Map<String, dynamic> _$$LeaderboardEntryImplToJson(
        _$LeaderboardEntryImpl instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'submissionId': instance.submissionId,
      'playerId': instance.playerId,
      'designId': instance.designId,
      'talentId': instance.talentId,
      'currentScore': instance.currentScore,
      'voteCount': instance.voteCount,
      'isGalaSovereign': instance.isGalaSovereign,
      'playerName': instance.playerName,
      'designName': instance.designName,
      'designImageUrl': instance.designImageUrl,
      'talentName': instance.talentName,
    };

_$VoteResultImpl _$$VoteResultImplFromJson(Map<String, dynamic> json) =>
    _$VoteResultImpl(
      success: json['success'] as bool,
      finalPoints: (json['finalPoints'] as num).toDouble(),
      message: json['message'] as String?,
      submissionId: json['submissionId'] as String?,
    );

Map<String, dynamic> _$$VoteResultImplToJson(_$VoteResultImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'finalPoints': instance.finalPoints,
      'message': instance.message,
      'submissionId': instance.submissionId,
    };
