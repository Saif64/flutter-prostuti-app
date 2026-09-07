import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:prostuti/core/services/socket_service.dart';
import 'package:prostuti/features/course/my_course/viewmodel/my_course_viewmodel.dart';

import '../viewmodel/notification_badge_viewmodel.dart';
import '../viewmodel/notification_viewmodel.dart';

// Wraps the logged-in app shell (HomeScreen) to react to real-time socket
// events without needing a BuildContext at the point the event arrives:
// toasts new course notices/enrollments, tracks the unread badge count, and
// refetches the REST notification/course lists whenever the socket
// (re)connects - this is how "missed notifications while offline" get
// caught up, since there's no backend "replay events since X" endpoint.
//
// Listeners are registered via ref.listenManual in initState (not ref.listen
// in build) specifically to get fireImmediately on the connection-status
// listener - WidgetRef.listen has no such flag, since Riverpod can't tell
// which listen call survived a rebuild and would otherwise replay a stale
// status on every rebuild.
class NotificationSocketListener extends ConsumerStatefulWidget {
  final Widget child;

  const NotificationSocketListener({super.key, required this.child});

  @override
  ConsumerState<NotificationSocketListener> createState() =>
      _NotificationSocketListenerState();
}

class _NotificationSocketListenerState
    extends ConsumerState<NotificationSocketListener> {
  @override
  void initState() {
    super.initState();

    ref.listenManual(courseNoticeStreamProvider, (previous, next) {
      next.whenData((event) {
        final name = event.courseName;
        Fluttertoast.showToast(
          msg: (name != null && name.isNotEmpty)
              ? 'New notice: $name'
              : 'New course notice',
        );
        ref.read(notificationBadgeCountProvider.notifier).increment();
        ref.invalidate(notificationViewModelProvider);
      });
    });

    ref.listenManual(courseEnrolledStreamProvider, (previous, next) {
      next.whenData((event) {
        final name = event.courseName;
        Fluttertoast.showToast(
          msg: (name != null && name.isNotEmpty)
              ? 'Enrolled in $name'
              : 'Course enrollment updated',
        );
        ref.invalidate(enrolledCourseViewmodelProvider);
      });
    });

    // Every transition into "connected" - first connect or a reconnect after
    // a drop - triggers a refetch, so missed events are caught up via REST
    // rather than requiring the socket to replay them. fireImmediately also
    // covers the case where the socket is already connected by the time
    // this widget mounts.
    ref.listenManual(socketConnectionStatusProvider, (previous, next) {
      next.whenData((status) {
        if (status == ConnectionStatus.connected) {
          ref.invalidate(notificationViewModelProvider);
          ref.invalidate(enrolledCourseViewmodelProvider);
        }
      });
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
