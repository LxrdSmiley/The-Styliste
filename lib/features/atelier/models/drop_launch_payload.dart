import '../../../domain/models/design.dart';
import '../../design/models/vex_review.dart';

class DropLaunchPayload {
  const DropLaunchPayload({
    required this.design,
    required this.hypeScore,
    this.review,
  });

  final Design design;
  final double hypeScore;
  final VexReview? review;
}
