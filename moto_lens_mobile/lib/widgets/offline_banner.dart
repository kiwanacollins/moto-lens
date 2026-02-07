import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import '../styles/styles.dart';

/// A slim, animated banner that slides in when the device goes offline
/// and shows sync progress when connectivity returns.
///
/// Place inside a [Column] at the top of any screen's body, or wrap
/// a screen's [Scaffold.body] with it via [OfflineBannerWrapper].
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, provider, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
          child: provider.showBanner
              ? _BannerContent(
                  key: ValueKey(provider.isOnline ? 'syncing' : 'offline'),
                  isOnline: provider.isOnline,
                  isSyncing: provider.isSyncing,
                  pendingCount: provider.pendingSyncCount,
                )
              : const SizedBox.shrink(key: ValueKey('hidden')),
        );
      },
    );
  }
}

class _BannerContent extends StatelessWidget {
  final bool isOnline;
  final bool isSyncing;
  final int pendingCount;

  const _BannerContent({
    super.key,
    required this.isOnline,
    required this.isSyncing,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final IconData icon;
    final String message;

    if (!isOnline) {
      bgColor = AppColors.warning;
      textColor = AppColors.carbonBlack;
      icon = Icons.cloud_off_rounded;
      message = 'You\'re offline — showing cached data';
    } else if (isSyncing) {
      bgColor = AppColors.electricBlue;
      textColor = Colors.white;
      icon = Icons.sync_rounded;
      message = pendingCount > 0
          ? 'Back online — syncing $pendingCount item${pendingCount == 1 ? '' : 's'}…'
          : 'Back online — syncing…';
    } else {
      bgColor = AppColors.success;
      textColor = Colors.white;
      icon = Icons.cloud_done_rounded;
      message = 'All changes synced';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(color: bgColor),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            isSyncing
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Icon(icon, size: 16, color: textColor),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Convenience wrapper that places the [OfflineBanner] above a child widget.
///
/// Use this to wrap a [Scaffold]'s body:
/// ```dart
/// Scaffold(
///   body: OfflineBannerWrapper(child: MyContent()),
/// )
/// ```
class OfflineBannerWrapper extends StatelessWidget {
  final Widget child;

  const OfflineBannerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OfflineBanner(),
        Expanded(child: child),
      ],
    );
  }
}
