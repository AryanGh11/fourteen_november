import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fourteen_november/theme/app_colors.dart';
import 'package:fourteen_november/theme/dark_theme.dart';
import 'package:fourteen_november/features/gift/gift.dart';
import 'package:fourteen_november/shared/app_messenger.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/shared/custom_circular_progress_indicator.dart';

part 'widgets/video.dart';
part 'widgets/reveal.dart';
part 'widgets/message.dart';

/// Plays a gift's video, then offers the gift itself once it has finished.
///
/// The gift button only exists after the video ends, so the video is always
/// seen first: the order the gift was meant to be opened in.
class GiftScreen extends StatefulWidget {
  final String giftId;

  const GiftScreen({super.key, required this.giftId});

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> with WidgetsBindingObserver {
  final _giftRepository = GiftRepository();

  Gift? _gift;
  VideoPlayerController? _controller;

  bool _loading = true;

  /// Set when the gift is missing, not open yet, or its video will not load.
  bool _unavailable = false;

  bool _ended = false;

  bool _saving = false;

  /// Where the PDF was saved, once it has been. Opening it again reuses the
  /// saved copy rather than downloading a second one into Downloads.
  String? _savedPath;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Paused rather than left playing to an empty room, so nothing of the
    // video is missed if the app is switched away from mid-way.
    if (state != AppLifecycleState.resumed) _controller?.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _controller?.removeListener(_onVideoChanged);
    _controller?.dispose();

    // The screen is only kept on while the video is up.
    WakelockPlus.disable();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dark throughout, as on the other full-screen views: the video is the
    // focus, and light text reads best over it.
    return Theme(
      data: darkTheme,
      child: Builder(
        builder: (context) {
          final colors = Theme.of(context).colorScheme;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Scaffold(
              backgroundColor: colors.surface,
              extendBodyBehindAppBar: true,
              appBar: DefaultAppBar(foregroundColor: colors.onSurface),
              body: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CustomCircularProgressIndicator());
    }

    final controller = _controller;

    if (_unavailable || controller == null) {
      return _Message(onRetry: _load);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _Video(controller: controller, onTap: _togglePlay),
        if (_ended)
          _Reveal(
            title: _gift?.title ?? '',
            saving: _saving,
            opened: _savedPath != null,
            onOpen: _openGift,
            onWatchAgain: _watchAgain,
          ),
      ],
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _unavailable = false;
    });

    try {
      final gift = await _giftRepository.fetch(widget.giftId);

      if (gift == null) throw StateError("Gift not available");

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(gift.videoUrl),
      );

      await controller.initialize();

      controller.addListener(_onVideoChanged);

      if (!mounted) {
        controller.dispose();
        return;
      }

      _gift = gift;
      _controller = controller;

      // A three minute video outlasts most screen timeouts; without this the
      // phone would dim and lock part way through.
      await WakelockPlus.enable();

      await controller.play();
    } catch (_) {
      _unavailable = true;
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _onVideoChanged() {
    final controller = _controller;

    if (controller == null || !controller.value.isCompleted || _ended) return;

    // Finished: the screen may sleep again, and the gift is revealed.
    WakelockPlus.disable();

    setState(() {
      _ended = true;
    });
  }

  void _togglePlay() {
    final controller = _controller;

    if (controller == null || _ended) return;

    controller.value.isPlaying ? controller.pause() : controller.play();

    setState(() {});
  }

  Future<void> _watchAgain() async {
    final controller = _controller;

    if (controller == null) return;

    await WakelockPlus.enable();
    await controller.seekTo(Duration.zero);
    await controller.play();

    setState(() {
      _ended = false;
    });
  }

  Future<void> _openGift() async {
    final gift = _gift;

    if (gift == null || _saving) return;

    setState(() {
      _saving = true;
    });

    try {
      final path = _savedPath ?? await _giftRepository.savePdfToDownloads(gift);

      _savedPath = path;

      final opened = await _giftRepository.openPdf(path);

      if (!opened && mounted) {
        // Saved but no viewer could open it; say where it is so it is not lost.
        AppMessenger.showSuccess(
          context,
          'هدیه‌ت تو پوشه‌ی Downloads ذخیره شد 🎁',
        );
      }
    } on GiftSaveException catch (e) {
      if (!mounted) return;

      AppMessenger.showError(
        context,
        e.failure == GiftSaveFailure.permissionDenied
            ? 'برای ذخیره‌ی هدیه باید اجازه‌ی دسترسی بدی'
            : 'دانلود نشد! نت رو چک کن و دوباره بزن',
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}
