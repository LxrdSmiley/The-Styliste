// GDD 5 + 6.1 - Mogul and system feed presentation.
// This widget reads existing feed content only and adds no backend behavior.

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/models/feed_post.dart';

class MogulPowerFeedCard extends StatelessWidget {
  const MogulPowerFeedCard({
    required this.post,
    required this.displayHype,
    required this.displayLikes,
    required this.onHype,
    required this.onLike,
    required this.onComment,
    super.key,
  });

  final FeedPost post;
  final double displayHype;
  final int displayLikes;
  final VoidCallback onHype;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> content = post.content;
    final bool isSystemEvent = post.type == 'system_eclipse';
    final Color accent = isSystemEvent ? AppColors.gold : AppColors.lime;
    final String brandName = _stringValue(
      content['brand_name'],
      fallback: isSystemEvent ? 'Global Market Desk' : 'Unknown Sovereign',
    );
    final String headline = isSystemEvent
        ? _stringValue(content['name'], fallback: 'ECLIPSE EVENT')
        : _mogulHeadline(content);
    final String supportCopy = isSystemEvent
        ? _stringValue(
            content['description'],
            fallback: 'A global market shift is underway.',
          )
        : _mogulSupportCopy(content);
    final List<_PowerMetric> metrics = isSystemEvent
        ? _systemMetrics(content)
        : _mogulMetrics(content, displayHype, displayLikes);

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.obsidian),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 18.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.obsidianSurface,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: accent.withValues(alpha: 0.34)),
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: _TickerBackdrop(accent: accent),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 20.0, 78.0, 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _TypeLine(
                      label: isSystemEvent ? 'BREAKING SIGNAL' : 'MOGUL FLEX',
                      color: accent,
                    ),
                    const Spacer(),
                    Text(
                      brandName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ivory.withValues(alpha: 0.64),
                        fontSize: 11.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      headline.toUpperCase(),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ivory,
                        fontSize: 34.0,
                        fontWeight: FontWeight.w900,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    Text(
                      supportCopy,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ivory.withValues(alpha: 0.72),
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: metrics.map((_PowerMetric metric) {
                        return _MetricChip(metric: metric, accent: accent);
                      }).toList(growable: false),
                    ),
                    const Spacer(),
                    _TickerStrip(accent: accent, isSystemEvent: isSystemEvent),
                  ],
                ),
              ),
              Positioned(
                right: 12.0,
                bottom: 24.0,
                child: _PowerActionRail(
                  accent: accent,
                  displayLikes: displayLikes,
                  actionsEnabled: !isSystemEvent,
                  onHype: onHype,
                  onLike: onLike,
                  onComment: onComment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeLine extends StatelessWidget {
  const _TypeLine({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8.0),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.4,
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.metric, required this.accent});

  final _PowerMetric metric;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
      decoration: BoxDecoration(
        color: AppColors.obsidian.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: accent.withValues(alpha: 0.38)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            metric.label,
            style: TextStyle(
              color: AppColors.ivory.withValues(alpha: 0.46),
              fontSize: 7.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 3.0),
          Text(
            metric.value,
            style: TextStyle(
              color: accent,
              fontSize: 13.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _TickerStrip extends StatelessWidget {
  const _TickerStrip({required this.accent, required this.isSystemEvent});

  final Color accent;
  final bool isSystemEvent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        isSystemEvent
            ? 'LIVE MARKET TRANSMISSION'
            : 'CAPITAL MOVES. DISTRICTS SHIFT. RIVALS NOTICE.',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: accent,
          fontSize: 9.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

class _TickerBackdrop extends StatelessWidget {
  const _TickerBackdrop({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            accent.withValues(alpha: 0.12),
            AppColors.obsidianSurface,
            AppColors.obsidian,
          ],
        ),
      ),
      child: CustomPaint(painter: _GridPainter(accent: accent)),
    );
  }
}

class _PowerActionRail extends StatelessWidget {
  const _PowerActionRail({
    required this.accent,
    required this.displayLikes,
    required this.actionsEnabled,
    required this.onHype,
    required this.onLike,
    required this.onComment,
  });

  final Color accent;
  final int displayLikes;
  final bool actionsEnabled;
  final VoidCallback onHype;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _RailButton(
          icon: Icons.local_fire_department_outlined,
          label: 'HYPE',
          color: accent,
          onTap: actionsEnabled ? onHype : null,
        ),
        _RailButton(
          icon: Icons.favorite_border,
          label: displayLikes.toString(),
          color: AppColors.ivory,
          onTap: actionsEnabled ? onLike : null,
        ),
        _RailButton(
          icon: Icons.mode_comment_outlined,
          label: 'COMMENT',
          color: AppColors.ivory,
          onTap: actionsEnabled ? onComment : null,
        ),
        const _RailButton(icon: Icons.bookmark_border, label: 'SAVE'),
        const _RailButton(icon: Icons.group_add, label: 'COLLAB'),
      ],
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  bool get _enabled => onTap != null;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor =
        color ?? AppColors.ivory.withValues(alpha: 0.32);
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: _enabled ? 1.0 : 0.46,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 42.0,
                height: 42.0,
                decoration: BoxDecoration(
                  color: AppColors.obsidian.withValues(alpha: 0.72),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: effectiveColor.withValues(alpha: 0.36),
                  ),
                ),
                child: Icon(icon, color: effectiveColor, size: 20.0),
              ),
              const SizedBox(height: 3.0),
              SizedBox(
                width: 54.0,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: effectiveColor,
                    fontSize: 7.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = accent.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;
    const double gap = 34.0;
    for (double x = 0.0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0.0), Offset(x, size.height), paint);
    }
    for (double y = 0.0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0.0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}

class _PowerMetric {
  const _PowerMetric({required this.label, required this.value});

  final String label;
  final String value;
}

String _mogulHeadline(Map<String, dynamic> content) {
  final String event = _stringValue(content['event'], fallback: 'power_move');
  if (event == 'store_upgraded') {
    final String city = _stringValue(content['city'], fallback: 'market');
    final String storeType =
        _stringValue(content['store_type'], fallback: 'store');
    final String tier = _stringValue(content['new_tier'], fallback: '1');
    return '${_formatToken(city)} ${_formatToken(storeType)} moved to T$tier';
  }
  return _formatToken(event);
}

String _mogulSupportCopy(Map<String, dynamic> content) {
  final String district = _firstPresent(content, <String>[
    'district',
    'market',
    'city',
  ]);
  final String influence = _firstPresent(content, <String>[
    'influence_copy',
    'influence',
    'control_copy',
  ]);
  final String rival = _firstPresent(content, <String>[
    'rival_pressure',
    'rival_pressure_copy',
    'rival',
  ]);

  final List<String> parts = <String>[
    if (district.isNotEmpty) 'Market: ${_formatToken(district)}.',
    if (influence.isNotEmpty) influence,
    if (rival.isNotEmpty) rival,
  ];
  return parts.isEmpty
      ? 'A public power move entered the market record.'
      : parts.join(' ');
}

List<_PowerMetric> _mogulMetrics(
  Map<String, dynamic> content,
  double displayHype,
  int displayLikes,
) {
  final List<_PowerMetric> metrics = <_PowerMetric>[
    _PowerMetric(label: 'HYPE', value: displayHype.toStringAsFixed(0)),
    _PowerMetric(label: 'LIKES', value: displayLikes.toString()),
  ];
  final String cashflow = _firstPresent(content, <String>[
    'cashflow',
    'cashflow_value',
    'revenue',
  ]);
  final String control = _firstPresent(content, <String>[
    'control',
    'control_value',
    'market_control',
  ]);
  if (cashflow.isNotEmpty) {
    metrics.add(_PowerMetric(label: 'CASHFLOW', value: cashflow));
  }
  if (control.isNotEmpty) {
    metrics.add(_PowerMetric(label: 'CONTROL', value: control));
  }
  return metrics.take(4).toList(growable: false);
}

List<_PowerMetric> _systemMetrics(Map<String, dynamic> content) {
  final String scope =
      _stringValue(content['affected_scope'], fallback: 'global');
  final String duration =
      _stringValue(content['duration_minutes'], fallback: '60');
  final double multiplier =
      _doubleValue(content['buff_multiplier'], fallback: 1.0);
  final String multiplierLabel = multiplier >= 1.0
      ? '+${((multiplier - 1.0) * 100).toStringAsFixed(0)}%'
      : '-${((1.0 - multiplier) * 100).toStringAsFixed(0)}%';

  return <_PowerMetric>[
    _PowerMetric(label: 'SHIFT', value: multiplierLabel),
    _PowerMetric(label: 'SCOPE', value: _formatToken(scope)),
    _PowerMetric(label: 'WINDOW', value: '${duration}MIN'),
  ];
}

String _firstPresent(Map<String, dynamic> content, List<String> keys) {
  for (final String key in keys) {
    final String value = _stringValue(content[key], fallback: '');
    if (value.isNotEmpty) return value;
  }
  return '';
}

String _stringValue(Object? value, {required String fallback}) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  if (value is num) return value.toString();
  return fallback;
}

double _doubleValue(Object? value, {required double fallback}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

String _formatToken(String value) {
  return value.replaceAll('_', ' ').trim();
}
