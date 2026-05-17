import 'package:flutter/material.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/shared/app_wrapper.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/shared/modals/add_mood_modal/add_mood_modal.dart';

part 'widgets/view.dart';
part 'widgets/list/list.dart';
part 'widgets/list/widgets/tile.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  List<Mood>? _moods;

  @override
  void initState() {
    _fetchMoods();
    super.initState();
  }

  Future<void> _fetchMoods() async {
    final res = await MoodRepository().getAll();

    setState(() {
      _moods = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: Text("Moods")),
      body: AppWrapper(
        child: _moods != null
            ? _View(moods: _moods!, onRefresh: _fetchMoods)
            : Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMoodModal,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddMoodModal() async {
    final res = await showAddMoodModal(context);
    if (res != null) _fetchMoods();
  }
}
