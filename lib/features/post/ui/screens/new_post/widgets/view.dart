part of '../new_post_screen.dart';

class _View extends StatelessWidget {
  final User user;
  final XFile? selectedImage;
  final Future<void> Function() onPickImage;
  final Widget Function(BuildContext context) buildAttachment;
  final TextEditingController descriptionController;

  const _View({
    required this.user,
    required this.selectedImage,
    required this.onPickImage,
    required this.buildAttachment,
    required this.descriptionController
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _Post(
        user: user,
        selectedImage: selectedImage,
        onPickImage: onPickImage,
        buildAttachment: buildAttachment,
        descriptionController: descriptionController,
      ),
    );
  }
}
