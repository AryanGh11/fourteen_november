part of '../new_post_screen.dart';

class _CreatePostButton extends StatelessWidget {
  final Future<void> Function(BuildContext context) onPressed;
  final bool loading;

  const _CreatePostButton({required this.onPressed, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LoadingElevatedButton(
        loading: loading,
        onPressed: () => onPressed(context),
        child: Text("Share Post"),
      ),
    );
  }
}
