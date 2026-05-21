import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/shared/app_wrapper.dart';
import 'package:fourteen_november/shared/app_messenger.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/shared/custom_cached_network_image.dart';
import 'package:fourteen_november/features/post/ui/widgets/cta_button.dart';
import 'package:fourteen_november/shared/buttons/loading_elevated_button.dart';

part 'widgets/view.dart';
part 'widgets/widgets/post.dart';
part 'widgets/create_post_button.dart';
part 'widgets/widgets/widgets/content.dart';
part 'widgets/widgets/widgets/cta_buttons.dart';
part 'widgets/widgets/widgets/description_row.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  XFile? _selectedImage;
  bool _creating = false;

  final _descriptionController = TextEditingController();
  final user = UserProviderService().current;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: DefaultAppBar(title: Text("New Memory")),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: AppWrapper(
          padding: EdgeInsets.all(10),
          child: _View(
            user: user!,
            selectedImage: _selectedImage,
            onPickImage: _pickImage,
            buildAttachment: _buildAttachment,
            descriptionController: _descriptionController,
          ),
        ),
      ),
      bottomNavigationBar: _CreatePostButton(
        loading: _creating,
        onPressed: _createPost,
      ),
    );
  }

  Future<void> _createPost(BuildContext context) async {
    if (_selectedImage == null || _descriptionController.text.isEmpty) return;

    setState(() {
      _creating = true;
    });

    try {
      await PostRepository().create(
        PostCreatePayload(
          attachmentPath: _selectedImage!.path,
          description: _descriptionController.text,
        ),
      );

      if (context.mounted) context.pop();
    } catch (_) {
      if (!context.mounted) return;
      AppMessenger.showError(
        context,
        'بخاطر نت پرسرعت ایران پابلیش نشد! لطفا دوباره بزن بوس',
      );
    } finally {
      setState(() {
        _creating = false;
      });
    }
  }

  Widget _buildAttachment(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_selectedImage != null) {
      return Image.file(File(_selectedImage!.path), fit: BoxFit.cover);
    }

    return Container(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          LucideIcons.imagePlus,
          size: 32,
          color: colors.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _selectedImage = image;
    });
  }
}
