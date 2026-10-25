import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fourteen_november/theme/app_colors.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/shared/app_wrapper.dart';
import 'package:fourteen_november/shared/app_messenger.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/shared/custom_circle_avatar.dart';
import 'package:fourteen_november/shared/buttons/loading_elevated_button.dart';
import 'package:fourteen_november/shared/custom_circular_progress_indicator.dart';

part 'widgets/view.dart';
part 'widgets/widgets/avatar.dart';

/// The current user's profile, where their name and avatar can be changed.
///
/// Both are saved to the server, so the other person sees the change too.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userRepository = UserRepository();
  final _picker = ImagePicker();

  late final TextEditingController _nameController;

  bool _savingName = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: UserProviderService().current?.name ?? '',
    );

    // Rebuilds as the name is typed, so Save can switch on only once the
    // name has actually changed.
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();

    super.dispose();
  }

  void _onNameChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: Text("Profile")),
      body: AppWrapper(
        child: ValueListenableBuilder(
          // Watches the users box so the avatar updates the moment an upload
          // lands, without a manual refresh.
          valueListenable: _userRepository.listenableBox(),
          builder: (context, Box<User> _, __) {
            final user = UserProviderService().current;

            if (user == null) return const SizedBox.shrink();

            final trimmed = _nameController.text.trim();
            final canSave =
                !_savingName && trimmed.isNotEmpty && trimmed != user.name;

            return _View(
              user: user,
              nameController: _nameController,
              uploadingAvatar: _uploadingAvatar,
              savingName: _savingName,
              onChangeAvatar: _uploadingAvatar ? null : _changeAvatar,
              onSaveName: canSave ? _saveName : null,
            );
          },
        ),
      ),
    );
  }

  Future<void> _changeAvatar() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      // An avatar is shown at most a few hundred pixels across; a smaller
      // file uploads more reliably over a slow connection.
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      _uploadingAvatar = true;
    });

    try {
      await _userRepository.updateAvatar(image.path);
    } catch (_) {
      if (!mounted) return;
      AppMessenger.showError(
        context,
        'عکس آپلود نشد! نت رو چک کن و دوباره امتحان کن',
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingAvatar = false;
        });
      }
    }
  }

  Future<void> _saveName() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _savingName = true;
    });

    try {
      final user = await _userRepository.updateName(_nameController.text);

      // Shows the saved form, without any trailing spaces that were trimmed.
      _nameController.text = user.name;

      if (!mounted) return;
      AppMessenger.showSuccess(context, 'اسمت عوض شد 🤍');
    } catch (_) {
      if (!mounted) return;
      AppMessenger.showError(
        context,
        'ذخیره نشد! نت رو چک کن و دوباره امتحان کن',
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingName = false;
        });
      }
    }
  }
}
