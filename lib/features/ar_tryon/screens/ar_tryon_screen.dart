// GDD §4.4 — AR Garment Try-On: camera viewport + HUD overlay (Phase 9).
//
// Architecture:
//   - StatefulWidget manages CameraController lifecycle (initState + dispose).
//   - Requests camera permission; surfaces denial state with retry CTA.
//   - Full-screen CameraPreview under a Stack HUD.
//   - HUD: back chevron (top-left), design name (top-right),
//          _GarmentOverlay (center — 2D placeholder for Phase 10 ML tracking),
//          capture button (bottom-center).
//   - enableAudio: false — no microphone permission required.
//   - ResolutionPreset.max — targets 60fps on supported hardware.
//   - Garment name hardcoded 'ALPHA PROTOTYPE' — Phase 10 wires real Design model.

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

class ArTryOnScreen extends StatefulWidget {
  const ArTryOnScreen({super.key});

  @override
  State<ArTryOnScreen> createState() => _ArTryOnScreenState();
}

class _ArTryOnScreenState extends State<ArTryOnScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _permissionDenied = false;
  bool _isCaptured = false; // brief flash state for capture button

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      ctrl.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _permissionDenied = true);
        return;
      }
      final CameraController ctrl = CameraController(
        cameras.first,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await ctrl.initialize();
      // Lock to portrait — fashion try-on is portrait-first.
      await ctrl.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _controller = ctrl;
        _isInitialized = true;
        _permissionDenied = false;
      });
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _permissionDenied =
              e.code == 'CameraAccessDenied' || e.code == 'CameraAccessDeniedWithoutPrompt';
        });
      }
    }
  }

  Future<void> _onCapture() async {
    setState(() => _isCaptured = true);
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (mounted) setState(() => _isCaptured = false);
    // Phase 10: save frame / share clip.
  }

  @override
  Widget build(BuildContext context) {
    // Force status bar to light icons over dark camera feed.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.obsidian,
        body: _permissionDenied
            ? _PermissionDeniedView(onRetry: _initCamera)
            : !_isInitialized
                ? const _LoadingView()
                : _CameraView(
                    controller: _controller!,
                    isCaptured: _isCaptured,
                    onBack: () => Navigator.of(context).pop(),
                    onCapture: _onCapture,
                  ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Camera view + HUD overlay stack
// ---------------------------------------------------------------------------
class _CameraView extends StatelessWidget {
  const _CameraView({
    required this.controller,
    required this.isCaptured,
    required this.onBack,
    required this.onCapture,
  });

  final CameraController controller;
  final bool isCaptured;
  final VoidCallback onBack;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // ── Full-screen camera preview ──────────────────────────────────
        CameraPreview(controller),

        // ── Vignette overlay for HUD legibility ────────────────────────
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.4,
              colors: <Color>[
                Colors.transparent,
                Colors.black.withValues(alpha: 0.4),
              ],
            ),
          ),
        ),

        // ── 2D garment overlay — Phase 10 ML body tracking placeholder ─
        const Positioned.fill(
          child: _GarmentOverlay(),
        ),

        // ── Top HUD bar ─────────────────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Back chevron
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: AppColors.ivory,
                      size: 22.0,
                    ),
                  ),
                ),
                const Spacer(),
                // Design name label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2.0),
                    border: Border.all(
                      color: AppColors.ivory.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Text(
                    'ALPHA PROTOTYPE',
                    style: TextStyle(
                      color: AppColors.ivory,
                      fontSize: 9.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Bottom HUD — capture button ─────────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Center(
                child: GestureDetector(
                  onTap: onCapture,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 68.0,
                    height: 68.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCaptured
                          ? AppColors.ivory.withValues(alpha: 0.9)
                          : Colors.transparent,
                      border: Border.all(
                        color: AppColors.ivory,
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: isCaptured ? 56.0 : 52.0,
                        height: isCaptured ? 56.0 : 52.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCaptured
                              ? AppColors.obsidian.withValues(alpha: 0.3)
                              : AppColors.ivory.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Garment overlay — 2D placeholder establishing the ML tracking pipeline.
// Phase 10: replace with ARKit/ARCore body-tracked mesh.
// ---------------------------------------------------------------------------
class _GarmentOverlay extends StatelessWidget {
  const _GarmentOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Silhouette placeholder — torso bounding box
          Container(
            width: 180.0,
            height: 260.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.25),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.gold.withValues(alpha: 0.08),
                  AppColors.gold.withValues(alpha: 0.04),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.checkroom_outlined,
                    color: AppColors.gold.withValues(alpha: 0.3),
                    size: 40.0,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'ALPHA PROTOTYPE',
                    style: TextStyle(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      fontSize: 8.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'TRACKING — PHASE 10',
                    style: TextStyle(
                      color: AppColors.ivory.withValues(alpha: 0.15),
                      fontSize: 7.0,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading state — camera initialising
// ---------------------------------------------------------------------------
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 16.0,
        height: 16.0,
        child: CircularProgressIndicator(
          color: AppColors.ivory,
          strokeWidth: 1.0,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Permission denied state — camera access required
// ---------------------------------------------------------------------------
class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.no_photography_outlined,
              color: AppColors.ivory.withValues(alpha: 0.2),
              size: 48.0,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'CAMERA ACCESS REQUIRED',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ivory,
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              'Enable camera permission in Settings to use the AR Try-On viewport.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ivory.withValues(alpha: 0.4),
                fontSize: 11.0,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28.0),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.ivory.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    color: AppColors.ivory,
                    fontSize: 9.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                'GO BACK',
                style: TextStyle(
                  color: AppColors.ivory.withValues(alpha: 0.3),
                  fontSize: 9.0,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
