import 'dart:async';

import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';

/// The "Write" FAB collapses to its icon while the feed scrolls down and
/// extends again when scrolling up or after a short pause. Never hidden:
/// writing must stay one tap away.
class ShrinkingWriteFab extends StatefulWidget {
  final VoidCallback onPressed;

  /// Attach this to a [NotificationListener] around the scrolling feed.
  final ValueNotifier<FeedScrollDirection> scrollDirection;

  const ShrinkingWriteFab({super.key, required this.onPressed, required this.scrollDirection});

  @override
  State<ShrinkingWriteFab> createState() => _ShrinkingWriteFabState();
}

enum FeedScrollDirection { idle, down, up }

class _ShrinkingWriteFabState extends State<ShrinkingWriteFab> {
  bool _extended = true;
  Timer? _idle;

  @override
  void initState() {
    super.initState();
    widget.scrollDirection.addListener(_onScroll);
  }

  void _onScroll() {
    _idle?.cancel();
    final direction = widget.scrollDirection.value;
    if (direction == FeedScrollDirection.down && _extended) setState(() => _extended = false);
    if (direction == FeedScrollDirection.up && !_extended) setState(() => _extended = true);
    _idle = Timer(AppMotion.fabReextendIdle, () {
      if (mounted && !_extended) setState(() => _extended = true);
    });
  }

  @override
  void dispose() {
    _idle?.cancel();
    widget.scrollDirection.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: widget.onPressed,
      isExtended: _extended,
      tooltip: 'Write an article',
      icon: const Icon(Icons.edit_rounded),
      label: const Text('Write'),
    );
  }
}
