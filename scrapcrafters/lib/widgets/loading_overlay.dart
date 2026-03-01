import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../theme/app_theme.dart';

/// Full-screen or inline loading overlay with SpinKit animations.
class LoadingOverlay extends StatelessWidget {
  final String message;
  final bool fullScreen;

  const LoadingOverlay({
    super.key,
    this.message = 'Loading...',
    this.fullScreen = true,
  });

  /// Show a modal loading overlay on top of the current screen.
  static void show(BuildContext context, {String message = 'Processing...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => LoadingOverlay(message: message),
    );
  }

  /// Dismiss the loading overlay.
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitFadingCube(color: AppTheme.primary, size: 40),
        const SizedBox(height: 20),
        Text(
          message,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (fullScreen) {
      return Material(
        color: Colors.transparent,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

/// Inline loading widget for smaller areas (e.g., inside buttons, cards).
class InlineLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const InlineLoader({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(color: color ?? AppTheme.primary, size: size);
  }
}

/// A status-aware loading wrapper that shows shimmer, error, or content.
class AsyncBuilder extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final Widget child;
  final Widget? loadingWidget;
  final VoidCallback? onRetry;

  const AsyncBuilder({
    super.key,
    required this.isLoading,
    this.error,
    required this.child,
    this.loadingWidget,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? const LoadingOverlay(fullScreen: false);
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppTheme.danger, size: 48),
              const SizedBox(height: 12),
              Text(
                error!,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return child;
  }
}
