part of '../../home_screen.dart';

const _monthlyAnniversaryAlertId = 'monthly-anniversary';

/// Drives the in-app alert dialog.
///
/// Renders nothing itself: it watches which alert is live and opens or closes
/// an [_AlertCard] over the screen.
///
/// Three things decide what is on screen:
/// - a ticker, because an alert opening at `startAt` or closing at `endAt` is
///   the passage of time rather than a cache write, so nothing else would
///   rebuild at that instant
/// - the app lifecycle, so returning to the app picks up an alert created
///   while it sat in the background
/// - the dialog closing, which is what records the dismissal
class _Alert extends StatefulWidget {
  const _Alert();

  @override
  State<_Alert> createState() => _AlertState();
}

class _AlertState extends State<_Alert> with WidgetsBindingObserver {
  final _repository = AlertRepository();

  Timer? _ticker;

  /// Id of the alert whose dialog is currently open, if any.
  String? _openId;

  /// Context of the open dialog, kept so it can be popped by route rather than
  /// by guessing at the navigator stack.
  BuildContext? _dialogContext;

  /// Set while closing the dialog because the window ended rather than because
  /// the reader closed it, so expiry is not recorded as a dismissal.
  bool _closedByExpiry = false;

  /// Alerts the reader closed since the app started.
  ///
  /// Kept apart from the remote dismissal so a failed write cannot reopen the
  /// dialog a second later; the cache would still say "not dismissed" and the
  /// ticker would otherwise put it straight back. If the write did fail, the
  /// alert simply returns on the next launch, which doubles as the retry.
  final Set<String> _closedThisSession = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _refresh();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _sync());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // An alert that started while the app was backgrounded is not in the cache,
    // because the remote query only returns windows that are already open.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  @override
  void dispose() {
    _ticker?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  /// Opens, closes or replaces the dialog so it matches the live alert.
  void _sync() {
    if (!mounted) return;

    final alert = _repository.current(excluding: _closedThisSession);

    // Open dialog no longer matches: its window closed, it was dismissed, or a
    // newer alert took over. Take it down; the next tick opens the new one.
    if (_openId != null && alert?.id != _openId) {
      _closedByExpiry = true;

      final dialogContext = _dialogContext;
      if (dialogContext != null && dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }

      return;
    }

    if (_openId == null && alert != null) _open(alert);
  }

  /// Pulls the currently live alerts.
  ///
  /// Failures are intentionally silent: an alert is incidental, and the home
  /// screen should not raise an error over something the reader never asked for.
  Future<void> _refresh() async {
    await _repository.syncIfNeeded();

    _sync();
  }

  Future<void> _open(Alert alert) async {
    // Held back until someone is chosen, both so the dialog does not stack on
    // top of the select-user modal and so a dismissal has an owner to record.
    if (UserProviderService().current == null) return;

    _openId = alert.id;
    _closedByExpiry = false;

    // showGeneralDialog does not carry the caller's theme into the overlay the
    // way showDialog does, so it is captured here to keep the home screen's
    // dark styling.
    final themes = InheritedTheme.capture(
      from: context,
      to: Navigator.of(context).context,
    );

    await showGeneralDialog<void>(
      context: context,
      // A non dismissible alert cannot be tapped away either.
      barrierDismissible: alert.dismissible,
      barrierLabel: "Dismiss alert",
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (dialogContext, _, __) {
        _dialogContext = dialogContext;

        return themes.wrap(
          PopScope(
            // Also blocks the Android back gesture, which would otherwise be a
            // way around a non dismissible alert.
            canPop: alert.dismissible,
            child: _AlertCard(
              alert: alert,
              celebratory: alert.id == _monthlyAnniversaryAlertId,
              onClose: () => Navigator.of(dialogContext).pop(),
            ),
          ),
        );
      },
      transitionBuilder: _transition,
    );

    _dialogContext = null;
    _openId = null;

    // Every route out of the dialog other than expiry is the reader closing
    // it: the button, the barrier, or the back gesture.
    if (!_closedByExpiry) {
      _closedThisSession.add(alert.id);

      if (alert.dismissible) unawaited(_dismiss(alert));
    }

    if (mounted) _sync();
  }

  /// Background blurs in while the card fades and settles from slightly
  /// smaller, so the alert arrives softly rather than snapping onto the screen.
  static Widget _transition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final blur = 10 * curved.value;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      ),
    );
  }

  /// Records the dismissal remotely.
  ///
  /// Silent on failure: the dialog is already closed for this session, and an
  /// error over something the reader just closed would be noise.
  Future<void> _dismiss(Alert alert) async {
    try {
      // Recorded remotely against the user id, so it survives a reinstall and
      // does not hide the alert from the other person.
      await _repository.dismiss(alert.id);
    } catch (_) {}
  }
}
