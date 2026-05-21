part of '../../../mood_screen.dart';

class _Tile extends StatefulWidget {
  final Mood mood;

  const _Tile({required this.mood});

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(widget.mood.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(Icons.delete, color: colors.onError),
      ),
      confirmDismiss: (_) async => _delete(),
      child: Stack(
        children: [
          _TileContent(mood: widget.mood),
          if (_deleting)
            Positioned.fill(
              child: const Center(child: CustomCircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<bool> _delete() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("حذف مود"),
              content: const Text(
                "مطمئنی میخواد مودت رو پاک کنی؟ آرین بفهمه ناراحت میشه ها 🥲",
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

    if (!confirmed) return false;

    setState(() {
      _deleting = true;
    });

    try {
      await MoodRepository().delete(widget.mood.id);

      return true;
    } catch (_) {
      if (mounted) {
        AppMessenger.showError(
          context,
          'اینقدر نت خوب بود حذف نشد (اشکال نداره حذفش نکن دیگه)',
        );
      }

      return false;
    } finally {
      setState(() {
        _deleting = false;
      });
    }
  }
}
