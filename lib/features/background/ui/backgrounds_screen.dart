import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fourteen_november/theme/dark_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fourteen_november/shared/app_messenger.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/shared/loading_icon_button.dart';
import 'package:fourteen_november/features/background/background.dart';
import 'package:fourteen_november/shared/custom_circular_progress_indicator.dart';

part 'widgets/view.dart';
part 'widgets/list/list.dart';
part 'widgets/list/widgets/tile.dart';

/// Full screen preview of every background, swiped through like a carousel.
///
/// Also where backgrounds are added and deleted. Changes here reach the home
/// screen's rotating backdrop as well, since both read the same cache.
class BackgroundsScreen extends StatefulWidget {
  const BackgroundsScreen({super.key});

  @override
  State<BackgroundsScreen> createState() => _BackgroundsScreenState();
}

class _BackgroundsScreenState extends State<BackgroundsScreen> {
  final _backgroundRepository = BackgroundRepository();
  final _pageController = PageController();
  final _picker = ImagePicker();

  int _index = 0;

  bool _adding = false;
  bool _deleting = false;

  /// Whether the app bar and counter are showing. Tapping the image hides
  /// them, so a background can be looked at without anything on top of it.
  bool _chromeVisible = true;

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dark theme throughout, as on the home screen: everything here sits over
    // a photo, where light text and icons read best.
    return Theme(
      data: darkTheme,
      child: ValueListenableBuilder(
        // Wraps the whole screen rather than just the body, because the app
        // bar's delete button needs to know which background is showing and
        // whether there are any left.
        valueListenable: _backgroundRepository.listenableBox(),
        builder: (context, Box<Background> box, _) {
          final colors = Theme.of(context).colorScheme;

          final backgrounds = _sorted(box);

          // A refresh or a delete can shrink the list under the current page.
          final index = backgrounds.isEmpty
              ? 0
              : _index.clamp(0, backgrounds.length - 1);

          final busy = _adding || _deleting;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Scaffold(
              backgroundColor: colors.surface,
              extendBodyBehindAppBar: true,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: AnimatedOpacity(
                  opacity: _chromeVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_chromeVisible,
                    child: DefaultAppBar(
                      title: Text("Backgrounds"),
                      foregroundColor: colors.onSurface,
                      actions: [
                        LoadingIconButton(
                          // Disabled while another change is in flight, and
                          // when there is nothing to delete.
                          onPressed: busy || backgrounds.isEmpty
                              ? null
                              : () => _delete(backgrounds[index]),
                          icon: const Icon(LucideIcons.trash2),
                          color: colors.error,
                          loading: _deleting,
                          loadingColor: colors.error,
                        ),
                        LoadingIconButton(
                          onPressed: busy ? null : _add,
                          icon: const Icon(LucideIcons.imagePlus),
                          loading: _adding,
                          loadingColor: colors.onSurface,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: _View(
                backgrounds: backgrounds,
                index: index,
                controller: _pageController,
                chromeVisible: _chromeVisible,
                onRefresh: _refresh,
                onPageChanged: (i) => setState(() => _index = i),
                onToggleChrome: () {
                  setState(() => _chromeVisible = !_chromeVisible);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// Newest first, so a background just added is the first page.
  List<Background> _sorted(Box<Background> box) {
    return _backgroundRepository.getAllFromBox(box)
      ..sort((a, b) => b.created.compareTo(a.created));
  }

  Future<void> _refresh() async {
    try {
      await _backgroundRepository.hardRefresh();
    } catch (_) {
      if (!mounted) return;
      AppMessenger.showError(
        context,
        'بخاطر نت پرسرعت ایران رفرش نشد! لطفا دوباره بکش پایین...',
      );
    }
  }

  Future<void> _add() async {
    if (_adding || _deleting) return;

    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      // Phone photos are often 5 to 12 MB. A backdrop never needs more than
      // a screen's worth of pixels, and a smaller file uploads far more
      // reliably over a slow connection and spends less of the free storage.
      maxWidth: 2560,
      maxHeight: 2560,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      _adding = true;
    });

    try {
      await _backgroundRepository.create(image.path);

      // Newest sorts first, so the one just added is page zero. Shown straight
      // away as confirmation that it worked.
      if (mounted && _pageController.hasClients) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    } catch (_) {
      if (!mounted) return;
      AppMessenger.showError(
        context,
        'آپلود نشد! نت رو چک کن و دوباره امتحان کن',
      );
    } finally {
      if (mounted) {
        setState(() {
          _adding = false;
        });
      }
    }
  }

  Future<void> _delete(Background background) async {
    if (_adding || _deleting) return;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("حذف بک‌گراند"),
              content: const Text(
                "مطمئنی میخوای این بک‌گراند رو پاک کنی؟ برای هردومون پاک میشه",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("بیخیال"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("حذف"),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    setState(() {
      _deleting = true;
    });

    try {
      await _backgroundRepository.delete(background.id);
    } catch (_) {
      if (!mounted) return;
      AppMessenger.showError(
        context,
        'حذف نشد! نت رو چک کن و دوباره امتحان کن',
      );
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
        });
      }
    }
  }
}
