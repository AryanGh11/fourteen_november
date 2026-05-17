part of '../../../mood_screen.dart';

class _Tile extends StatefulWidget {
  final Mood mood;

  const _Tile({required this.mood});

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  User? _moodUser;

  @override
  void initState() {
    _fetchMoodUser();
    super.initState();
  }

  Future<void> _fetchMoodUser() async {
    final moodUser = await widget.mood.user;
    setState(() {
      _moodUser = moodUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surface,
      child: Row(children: [if (_moodUser != null) Text(_moodUser!.name)]),
    );
  }
}
