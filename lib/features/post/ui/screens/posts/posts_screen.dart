import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/shared/app_wrapper.dart';
import 'package:fourteen_november/shared/app_messenger.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/core/router/route_provider.dart';
import 'package:fourteen_november/shared/custom_cached_network_image.dart';
import 'package:fourteen_november/features/post/ui/widgets/cta_button.dart';

part 'widgets/view.dart';
part 'widgets/widgets/list.dart';
part 'widgets/widgets/widgets/post.dart';
part 'widgets/widgets/widgets/widgets/content.dart';
part 'widgets/widgets/widgets/widgets/attachment.dart';
part 'widgets/widgets/widgets/widgets/cta_buttons.dart';
part 'widgets/widgets/widgets/widgets/description_row.dart';

class PostsScreen extends StatelessWidget {
  PostsScreen({super.key});

  final postRepository = PostRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: Text("Our Memories")),
      body: AppWrapper(
        padding: EdgeInsets.all(10),
        child: ValueListenableBuilder(
          valueListenable: postRepository.listenableBox(),
          builder: (context, Box<Post> box, _) {
            final posts = postRepository.getAllFromBox(box)
              ..sort((a, b) => b.created.compareTo(a.created));
            return _View(posts: posts, onRefresh: () => _refresh(context));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNewPostScreen(context),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _navigateToNewPostScreen(BuildContext context) {
    context.push(RouteProvider.newPost);
  }

  Future<void> _refresh(BuildContext context) async {
    try {
      await postRepository.hardRefresh();
    } catch (_) {
      if (!context.mounted) return;
      AppMessenger.showError(
        context,
        'بخاطر نت پرسرعت ایران رفرش نشد! لطفا دوباره بکش پایین...',
      );
    }
  }
}
