import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_badge_viewmodel.g.dart';

// Unread course-notice count shown as a badge on the bottom-nav Notification
// tab. Backend exposes no separate unread-count endpoint, so this is tracked
// client-side: incremented on each COURSE_NOTICE_NOTIFICATION socket event,
// reset when the student opens the Notification tab.
@Riverpod(keepAlive: true)
class NotificationBadgeCount extends _$NotificationBadgeCount {
  @override
  int build() => 0;

  void increment() => state = state + 1;

  void reset() => state = 0;
}
