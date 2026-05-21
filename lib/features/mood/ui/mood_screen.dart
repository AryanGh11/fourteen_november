import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/shared/app_wrapper.dart';
import 'package:fourteen_november/shared/app_messenger.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fourteen_november/shared/custom_circular_progress_indicator.dart';
import 'package:fourteen_november/shared/dialogs/add_mood_dialog/add_mood_dialog.dart';

part 'widgets/view.dart';
part 'widgets/list/list.dart';
part 'widgets/list/widgets/tile.dart';
part 'widgets/list/widgets/widgets/content.dart';

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
            return _View(moods: moods, onRefresh: () => _refresh(context));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMoodModal(context),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _showAddMoodModal(BuildContext context) async {
    await showAddMoodDialog(context);
  }

  Future<void> _refresh(BuildContext context) async {
    try {
      await moodRepository.hardRefresh();
    } catch (_) {
      if (!context.mounted) return;
      AppMessenger.showError(
        context,
        'بخاطر نت پرسرعت ایران رفرش نشد! لطفا دوباره بکش پایین...',
      );
    }
  }
}
