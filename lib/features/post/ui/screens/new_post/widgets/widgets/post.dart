part of '../../new_post_screen.dart';

class _Post extends StatelessWidget {
  final User user;
  final XFile? selectedImage;
  final Future<void> Function() onPickImage;
  final Widget Function(BuildContext context) buildAttachment;
  final TextEditingController descriptionController;

  const _Post({
    required this.user,
    required this.selectedImage,
    required this.onPickImage,
    required this.buildAttachment,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 1 / 1,
              child: GestureDetector(
                onTap: onPickImage,
                child: buildAttachment(context),
              ),
            ),
            Positioned(top: 0, left: 0, right: 0, child: _Content(user: user)),
          ],
        ),
        SizedBox(height: 8),
        _CTAButtons(),
        SizedBox(height: 4),
        _DescriptionRow(
          descriptionController: descriptionController,
          user: user,
        ),
      ],
    );
  }
}
