import 'package:flutter/material.dart';
import 'package:fourteen_november/shared/custom_circular_progress_indicator.dart';

class PostScreenCTAButton extends StatelessWidget {
  final int count;
  final Widget icon;
  final Future<void> Function()? onTap;
  final bool loading;

  const PostScreenCTAButton({
    super.key,
    required this.count,
    required this.icon,
    required this.onTap,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: BoxConstraints(minWidth: 40),
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: Row(
          spacing: 4,
          children: [
            loading
                ? Container(
                    padding: EdgeInsets.all(4),
                    width: 24,
                    height: 24,
                    child: Center(child: CustomCircularProgressIndicator()),
                  )
                : icon,
            Text(
              count.toString(),
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
