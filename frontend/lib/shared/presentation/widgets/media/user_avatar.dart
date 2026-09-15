import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/initials_formatter.dart';

/// Circular avatar: the photo when available, otherwise serif initials.
/// The signed-in user gets the lilac container; other authors the outline tint.
class UserAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double size;
  final bool isCurrentUser;

  /// Draws a white ring and soft shadow (Profile header).
  final bool ringed;

  const UserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = 48,
    this.isCurrentUser = false,
    this.ringed = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    final Widget avatar = hasPhoto
        ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: photoUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _Initials(name: name, size: size, isCurrentUser: isCurrentUser),
            ),
          )
        : _Initials(name: name, size: size, isCurrentUser: isCurrentUser);

    if (!ringed) return SizedBox(width: size, height: size, child: avatar);

    return Container(
      width: size + 8,
      height: size + 8,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: avatar,
    );
  }
}

class _Initials extends StatelessWidget {
  final String name;
  final double size;
  final bool isCurrentUser;

  const _Initials({required this.name, required this.size, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isCurrentUser ? palette.primaryContainer : palette.tint,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        InitialsFormatter.of(name),
        style: AppTypography.serifGlyph(size * 0.4, weight: FontWeight.w600)
            .copyWith(color: isCurrentUser ? palette.onPrimaryContainer : palette.primaryDeep),
      ),
    );
  }
}
