import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prostuti/core/services/localization_service.dart';
import 'package:prostuti/core/services/socket_service.dart';

class ChatConnectionStatus extends ConsumerWidget {
  const ChatConnectionStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(socketConnectionStatusProvider);

    return connectionStatus.when(
      data: (status) {
        if (status == ConnectionStatus.connected) {
          // When connected show a temporary success indicator that fades out
          return FadeOutConnectionStatus(
            backgroundColor: Colors.green.withOpacity(0.8),
            message: 'Connected',
            icon: Icons.check_circle,
            duration: const Duration(seconds: 1),
          );
        }

        Color backgroundColor;
        String message;
        IconData icon;
        bool showRetry = false;

        switch (status) {
          case ConnectionStatus.connecting:
            backgroundColor = Colors.orange.withOpacity(0.8);
            message = context.l10n?.connecting ?? 'Connecting...';
            icon = Icons.sync;
            break;
          case ConnectionStatus.connectionError:
            backgroundColor = Colors.red.withOpacity(0.8);
            message = context.l10n?.connectionError ??
                'Connection error. Retrying...';
            icon = Icons.error_outline;
            showRetry = true;
            break;
          case ConnectionStatus.authError:
            backgroundColor = Colors.red.withOpacity(0.8);
            message = context.l10n?.authError ?? 'Authentication error';
            icon = Icons.lock;
            showRetry = true;
            break;
          default:
            backgroundColor = Colors.orange.withOpacity(0.8);
            message = context.l10n?.disconnected ?? 'Disconnected';
            icon = Icons.cloud_off;
            showRetry = true;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          color: backgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (status == ConnectionStatus.connecting)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (showRetry) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    // Attempt to reconnect manually
                    SocketService().disconnect();
                    SocketService().initSocket();
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                  child: Text(
                    context.l10n?.retry ?? 'Retry',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        color: Colors.blue.withOpacity(0.8),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Initializing connection...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      error: (error, _) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        color: Colors.red.withOpacity(0.8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '${context.l10n?.connectionError ?? 'Connection error'}: $error',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FadeOutConnectionStatus extends StatefulWidget {
  final Color backgroundColor;
  final String message;
  final IconData icon;
  final Duration duration;

  const FadeOutConnectionStatus({
    super.key,
    required this.backgroundColor,
    required this.message,
    required this.icon,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<FadeOutConnectionStatus> createState() =>
      _FadeOutConnectionStatusState();
}

class _FadeOutConnectionStatusState extends State<FadeOutConnectionStatus>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Create opacity animation
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Create height animation
    _heightAnimation = CurvedAnimation(
      parent: _controller,
      // Use a slightly different curve for height to create a nice visual effect
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // When animation completes, return an empty SizedBox to remove from layout
        if (_controller.status == AnimationStatus.completed) {
          return const SizedBox.shrink();
        }

        return FadeTransition(
          opacity:
              Tween<double>(begin: 1.0, end: 0.0).animate(_opacityAnimation),
          child: SizeTransition(
            sizeFactor:
                Tween<double>(begin: 1.0, end: 0.0).animate(_heightAnimation),
            axisAlignment: -1.0, // Top alignment
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: widget.backgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
