// GDD 4.1 + 6.1 + 8.7.1 - Designer Alpha Drop feed presentation.
// This widget is visual only; mutations remain in the existing feed providers.

import 'package:flutter/material.dart';

import '../../../core/theme/styliste_colors.dart';
import '../../../domain/models/feed_post.dart';

class AlphaDropFeedCard extends StatelessWidget {
  const AlphaDropFeedCard({
    required this.post,
    required this.displayHype,
    required this.displayLikes,
    required this.onHype,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.onInspiration,
    required this.inspirationLabel,
    super.key,
  });

  final FeedPost post;
  final double displayHype;
  final int displayLikes;
  final VoidCallback? onHype;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onSave;
  final VoidCallback? onInspiration;
  final String inspirationLabel;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> content = post.content;
    final String brandName =
        _stringValue(content['brand_name'], fallback: 'Unknown Sovereign');
    final String designName =
        _stringValue(content['design_name'], fallback: 'UNTITLED ALPHA');
    final double hypeScore =
        _doubleValue(content['hype_score'], fallback: displayHype);
    final int? brandRank = _intValue(content['brand_rank']);
    final Color fabricColor = _hexToColor(
      _stringValue(content['fabric_color_hex'], fallback: 'FAF7F0'),
    );
    final List<String> trendTags = _stringList(content['trend_tags']).isNotEmpty
        ? _stringList(content['trend_tags'])
        : _stringList(content['style_tags']);
    final String editorialNote = _firstNonEmpty(<Object?>[
      content['result_explanation'],
      content['editorial_note'],
      content['caption'],
    ]);

    final bool highHype = hypeScore >= 80.0;
    final bool weakHype = hypeScore < 40.0;
    final Color accent =
        weakHype ? StylisteColors.deepGold : StylisteColors.champagneGold;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: StylisteColors.obsidian,
        boxShadow: highHype
            ? <BoxShadow>[
                BoxShadow(
                  color: StylisteColors.champagneGold.withValues(alpha: 0.16),
                  blurRadius: 44.0,
                  spreadRadius: 4.0,
                ),
              ]
            : null,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool useAccessibleLayout =
              MediaQuery.textScalerOf(context).scale(1.0) > 1.3 ||
                  constraints.maxWidth < 340.0;
          final Widget editorialPanel = _EditorialPanel(
            accent: accent,
            brandName: brandName,
            designName: designName,
            brandRank: brandRank,
            hypeScore: hypeScore,
            displayHype: displayHype,
            editorialNote: editorialNote,
            trendTags: trendTags,
          );
          final Widget actionRail = _ActionRail(
            accent: accent,
            displayLikes: displayLikes,
            onHype: onHype,
            onLike: onLike,
            onComment: onComment,
            onSave: onSave,
            onInspiration: onInspiration,
            inspirationLabel: inspirationLabel,
          );

          if (useAccessibleLayout) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 280.0,
                    child: _LookbookStage(
                      fabricColor: fabricColor,
                      accent: accent,
                      highHype: highHype,
                      weakHype: weakHype,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  editorialPanel,
                  const SizedBox(height: 12.0),
                  _AccessibleActionBar(
                    accent: accent,
                    displayLikes: displayLikes,
                    onHype: onHype,
                    onLike: onLike,
                    onComment: onComment,
                    onSave: onSave,
                    onInspiration: onInspiration,
                    inspirationLabel: inspirationLabel,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 18.0),
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: _LookbookStage(
                        fabricColor: fabricColor,
                        accent: accent,
                        highHype: highHype,
                        weakHype: weakHype,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    editorialPanel,
                  ],
                ),
                Positioned(right: 8.0, top: 42.0, child: actionRail),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LookbookStage extends StatelessWidget {
  const _LookbookStage({
    required this.fabricColor,
    required this.accent,
    required this.highHype,
    required this.weakHype,
  });

  final Color fabricColor;
  final Color accent;
  final bool highHype;
  final bool weakHype;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: weakHype
            ? StylisteColors.obsidianSurface
            : StylisteColors.obsidianSurface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.lerp(fabricColor, StylisteColors.obsidian, 0.18) ??
                fabricColor,
            StylisteColors.obsidianSurface,
            StylisteColors.obsidian,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (highHype)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.82,
                  colors: <Color>[
                    StylisteColors.champagneGold.withValues(alpha: 0.28),
                    StylisteColors.transparent,
                  ],
                ),
              ),
            ),
          Center(
            child: CustomPaint(
              size: const Size(176.0, 300.0),
              painter: _MannequinPainter(
                fabricColor: fabricColor,
                accent: accent,
                weakHype: weakHype,
              ),
            ),
          ),
          Positioned(
            left: 16.0,
            top: 16.0,
            child: _LabelPill(label: 'DESIGN RECORD', color: accent),
          ),
          Positioned(
            left: 16.0,
            bottom: 16.0,
            child: Text(
              'HOUSE FEED RECORD',
              style: TextStyle(
                color: StylisteColors.ivory.withValues(alpha: 0.5),
                fontSize: 9.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialPanel extends StatelessWidget {
  const _EditorialPanel({
    required this.accent,
    required this.brandName,
    required this.designName,
    required this.hypeScore,
    required this.displayHype,
    required this.editorialNote,
    required this.trendTags,
    this.brandRank,
  });

  final Color accent;
  final String brandName;
  final String designName;
  final int? brandRank;
  final double hypeScore;
  final double displayHype;
  final String editorialNote;
  final List<String> trendTags;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: StylisteColors.ivory,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  brandRank == null ? brandName : '$brandName - R$brandRank',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: StylisteColors.obsidian,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              _HypeBadge(score: hypeScore, accent: accent),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            designName.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: StylisteColors.obsidian,
              fontSize: 26.0,
              fontWeight: FontWeight.w900,
              height: 0.96,
            ),
          ),
          if (editorialNote.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0),
              decoration: BoxDecoration(
                color: StylisteColors.obsidian,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'CAUSES',
                    style: TextStyle(
                      color: accent,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      editorialNote,
                      style: const TextStyle(
                        color: StylisteColors.ivory,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (trendTags.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10.0),
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: trendTags.take(4).map((String tag) {
                return _TagChip(label: tag, color: accent);
              }).toList(growable: false),
            ),
          ],
          const SizedBox(height: 10.0),
          Text(
            '${displayHype.toStringAsFixed(0)} PUBLIC HYPE',
            style: TextStyle(
              color: StylisteColors.obsidian.withValues(alpha: 0.56),
              fontSize: 10.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _HypeBadge extends StatelessWidget {
  const _HypeBadge({required this.score, required this.accent});

  final double score;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          const Text(
            'HOUSE SIGNAL',
            style: TextStyle(
              color: StylisteColors.obsidian,
              fontSize: 7.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              color: StylisteColors.obsidian,
              fontSize: 18.0,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({
    required this.accent,
    required this.displayLikes,
    required this.onHype,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.onInspiration,
    required this.inspirationLabel,
  });

  final Color accent;
  final int displayLikes;
  final VoidCallback? onHype;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onSave;
  final VoidCallback? onInspiration;
  final String inspirationLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _RailButton(
          icon: Icons.local_fire_department_outlined,
          label: 'HYPE',
          color: accent,
          onTap: onHype,
        ),
        _RailButton(
          icon: Icons.favorite_border,
          label: displayLikes.toString(),
          color: StylisteColors.ivory,
          onTap: onLike,
        ),
        _RailButton(
          icon: Icons.mode_comment_outlined,
          label: 'COMMENT',
          color: StylisteColors.ivory,
          onTap: onComment,
        ),
        _RailButton(
          icon: Icons.bookmark_border,
          label: 'SAVE',
          color: StylisteColors.ivory,
          onTap: onSave,
        ),
        _RailButton(
          icon: Icons.palette_outlined,
          label: inspirationLabel,
          color: StylisteColors.ivory,
          onTap: onInspiration,
        ),
      ],
    );
  }
}

class _AccessibleActionBar extends StatelessWidget {
  const _AccessibleActionBar({
    required this.accent,
    required this.displayLikes,
    required this.onHype,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.onInspiration,
    required this.inspirationLabel,
  });

  final Color accent;
  final int displayLikes;
  final VoidCallback? onHype;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onSave;
  final VoidCallback? onInspiration;
  final String inspirationLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4.0,
      runSpacing: 8.0,
      children: <Widget>[
        _RailButton(
          icon: Icons.local_fire_department_outlined,
          label: 'HYPE',
          color: accent,
          onTap: onHype,
        ),
        _RailButton(
          icon: Icons.favorite_border,
          label: displayLikes.toString(),
          color: StylisteColors.ivory,
          onTap: onLike,
        ),
        _RailButton(
          icon: Icons.mode_comment_outlined,
          label: 'COMMENT',
          color: StylisteColors.ivory,
          onTap: onComment,
        ),
        _RailButton(
          icon: Icons.bookmark_border,
          label: 'SAVE',
          color: StylisteColors.ivory,
          onTap: onSave,
        ),
        _RailButton(
          icon: Icons.palette_outlined,
          label: inspirationLabel,
          color: StylisteColors.ivory,
          onTap: onInspiration,
        ),
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
        color ?? StylisteColors.ivory.withValues(alpha: 0.32);
    return Padding(
      padding: const EdgeInsets.only(top: 9.0),
      child: Semantics(
        button: true,
        enabled: _enabled,
        label: label,
        child: Opacity(
          opacity: _enabled ? 1.0 : 0.46,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox.square(
                dimension: 48,
                child: IconButton(
                  tooltip: label,
                  onPressed: onTap,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        StylisteColors.obsidian.withValues(alpha: 0.72),
                    side: BorderSide(
                      color: effectiveColor.withValues(alpha: 0.38),
                    ),
                  ),
                  icon: Icon(icon, color: effectiveColor, size: 20),
                ),
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

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: color.withValues(alpha: 0.44)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: StylisteColors.obsidian,
          fontSize: 8.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _LabelPill extends StatelessWidget {
  const _LabelPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: StylisteColors.obsidian.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: color.withValues(alpha: 0.48)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

class _MannequinPainter extends CustomPainter {
  const _MannequinPainter({
    required this.fabricColor,
    required this.accent,
    required this.weakHype,
  });

  final Color fabricColor;
  final Color accent;
  final bool weakHype;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2.0, size.height / 2.0);
    final Paint glow = Paint()
      ..color = accent.withValues(alpha: weakHype ? 0.08 : 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.8,
        height: size.height * 0.92,
      ),
      glow,
    );

    final Path dress = Path()
      ..moveTo(center.dx - size.width * 0.22, size.height * 0.17)
      ..cubicTo(
        center.dx - size.width * 0.54,
        size.height * 0.33,
        center.dx - size.width * 0.44,
        size.height * 0.78,
        center.dx,
        size.height * 0.92,
      )
      ..cubicTo(
        center.dx + size.width * 0.44,
        size.height * 0.78,
        center.dx + size.width * 0.54,
        size.height * 0.33,
        center.dx + size.width * 0.22,
        size.height * 0.17,
      )
      ..quadraticBezierTo(
        center.dx,
        size.height * 0.28,
        center.dx - size.width * 0.22,
        size.height * 0.17,
      )
      ..close();

    final Rect bounds = dress.getBounds();
    final Paint fabric = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          weakHype
              ? Color.lerp(fabricColor, StylisteColors.obsidianRaised, 0.56) ??
                  fabricColor
              : fabricColor,
          Color.lerp(fabricColor, StylisteColors.obsidian, 0.35) ?? fabricColor,
          accent.withValues(alpha: 0.72),
        ],
      ).createShader(bounds);
    canvas.drawPath(dress, fabric);

    final Paint edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..color = StylisteColors.ivory.withValues(alpha: weakHype ? 0.28 : 0.56);
    canvas.drawPath(dress, edge);

    final Paint stand = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = StylisteColors.ivory.withValues(alpha: 0.28);
    canvas
      ..drawLine(
        Offset(center.dx, size.height * 0.92),
        Offset(center.dx, size.height),
        stand,
      )
      ..drawLine(
        Offset(center.dx - size.width * 0.22, size.height),
        Offset(center.dx + size.width * 0.22, size.height),
        stand,
      );
  }

  @override
  bool shouldRepaint(covariant _MannequinPainter oldDelegate) {
    return oldDelegate.fabricColor != fabricColor ||
        oldDelegate.accent != accent ||
        oldDelegate.weakHype != weakHype;
  }
}

String _stringValue(Object? value, {required String fallback}) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return fallback;
}

String _firstNonEmpty(List<Object?> values) {
  for (final Object? value in values) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return '';
}

double _doubleValue(Object? value, {required double fallback}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

List<String> _stringList(Object? value) {
  if (value is! List) return <String>[];
  return value
      .map((Object? item) => item?.toString().trim() ?? '')
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}

Color _hexToColor(String hex) {
  try {
    final String clean = hex.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {
    return StylisteColors.ivory;
  }
}
