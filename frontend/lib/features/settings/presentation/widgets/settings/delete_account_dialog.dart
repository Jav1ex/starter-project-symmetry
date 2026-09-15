import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/destructive_button.dart';

/// Confirmation for deleting the account. The red button stays disabled
/// until the user ticks that they understand it cannot be undone.
///
/// Resolves to `true` only when the user confirmed.
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  static const String title = 'Delete your account?';
  static const String body =
      'Your profile and your published articles will be permanently deleted. '
      'Saved articles from other writers are not affected.';
  static const String acknowledgement = "I understand this can't be undone";

  static Future<bool> show(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteAccountDialog(),
    );
    return confirmed ?? false;
  }

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  bool _understood = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: palette.errorContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.delete_forever_rounded, color: palette.error),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              DeleteAccountDialog.title,
              style: AppTypography.dialogTitle.copyWith(color: palette.ink),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              DeleteAccountDialog.body,
              style: AppTypography.bodySmall.copyWith(color: palette.inkBody),
            ),
            const SizedBox(height: AppSpacing.lg),
            CheckboxListTile(
              value: _understood,
              onChanged: (value) => setState(() => _understood = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(
                DeleteAccountDialog.acknowledgement,
                style: AppTypography.bodySmall.copyWith(color: palette.ink),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DestructiveButton(
              label: 'Yes, delete my account',
              filled: true,
              onPressed: _understood ? () => Navigator.of(context).pop(true) : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(minimumSize: const Size.fromHeight(AppSizes.button)),
              child: const Text('Keep my account'),
            ),
          ],
        ),
      ),
    );
  }
}
