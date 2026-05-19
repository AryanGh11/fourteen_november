import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/shared/app_wrapper.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/shared/modals/add_mood_modal/add_mood_modal.dart';

part 'widgets/view.dart';
part 'widgets/list/list.dart';
part 'widgets/list/widgets/tile.dart';

class MoodScreen extends StatelessWidget {
  MoodScreen({super.key});

  final moodRepository = MoodRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: Text("Moods")),
      body: AppWrapper(
        child: ValueListenableBuilder(
          valueListenable: moodRepository.listenableBox(),
          builder: (context, Box<Mood> box, _) {
            final moods = moodRepository.getAllFromBox(box)
              ..sort((a, b) => b.created.compareTo(a.created));
            return _View(moods: moods, onRefresh: moodRepository.hardRefresh);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMoodModal(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddMoodModal(BuildContext context) async {
    await showAddMoodModal(context);
  }
}
