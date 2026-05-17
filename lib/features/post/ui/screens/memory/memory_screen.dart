import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/shared/app_wrapper.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/shared/custom_cached_network_image.dart';

part 'widgets/view.dart';
part 'widgets/post/post.dart';
part 'widgets/post/widgets/content.dart';
part 'widgets/post/widgets/description_row.dart';
part 'widgets/post/widgets/cta_buttons/cta_buttons.dart';
part 'widgets/post/widgets/cta_buttons/widgets/button.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  List<Post>? _posts;

  @override
  void initState() {
    _fetchPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: Text("Our Memories")),
      body: RefreshIndicator(
        onRefresh: _fetchPosts,
        child: AppWrapper(
          padding: EdgeInsets.all(10),
          child: _View(posts: _posts, onPostChanged: _fetchPosts),
        ),
      ),
    );
  }

  Future<void> _fetchPosts() async {
    final res = await PostRepository().getAll();

    setState(() {
      _posts = res;
    });
  }
}
