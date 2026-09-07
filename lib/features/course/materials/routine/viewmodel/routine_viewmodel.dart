import 'package:intl/intl.dart';
import 'package:prostuti/features/course/course_details/viewmodel/course_details_vm.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../common/widgets/time_converter.dart';
import '../../../course_details/model/course_details_model.dart';

part 'routine_viewmodel.g.dart';

class RoutineActivity {
  final String type; // Class, Assignment, Exam
  final String title;
  final DateTime date;
  final String timeString;
  final String? details;
  final String? id;

  RoutineActivity({
    required this.type,
    required this.title,
    required this.date,
    required this.timeString,
    this.details,
    this.id,
  });
}

@riverpod
class RoutineViewModel extends _$RoutineViewModel {
  @override
  FutureOr<List<RoutineActivity>> build() async {
    final courseDetailsAsync =
        await ref.watch(courseDetailsViewmodelProvider.future);
    return _parseActivities(courseDetailsAsync);
  }

  List<RoutineActivity> _parseActivities(CourseDetails courseDetails) {
    List<RoutineActivity> activities = [];

    if (courseDetails.data?.lessons == null) return activities;

    for (var lesson in courseDetails.data!.lessons!) {
      // Parse recorded classes
      if (lesson.recodedClasses != null) {
        for (var recordedClass in lesson.recodedClasses!) {
          if (recordedClass.classDate != null) {
            final dateTime =
                TimeConverter.toDhakaTime(DateTime.parse(recordedClass.classDate!));
            activities.add(RoutineActivity(
              type: 'Class',
              title: recordedClass.recodeClassName ?? 'Class',
              date: dateTime,
              timeString: DateFormat('hh:mm a').format(dateTime),
              details: recordedClass.classDetails,
              id: recordedClass.sId,
            ));
          }
        }
      }

      // Parse assignments
      if (lesson.assignments != null) {
        for (var assignment in lesson.assignments!) {
          if (assignment.unlockDate != null) {
            final dateTime =
                TimeConverter.toDhakaTime(DateTime.parse(assignment.unlockDate!));
            activities.add(RoutineActivity(
              type: 'Assignment',
              title: assignment.assignmentNo ?? 'Assignment',
              date: dateTime,
              timeString: DateFormat('hh:mm a').format(dateTime),
              details: assignment.details,
              id: assignment.sId,
            ));
          }
        }
      }

      // Parse tests
      if (lesson.tests != null) {
        for (var test in lesson.tests!) {
          if (test.publishDate != null) {
            final dateTime =
                TimeConverter.toDhakaTime(DateTime.parse(test.publishDate!));
            activities.add(RoutineActivity(
              type: 'Exam',
              title: test.name ?? 'Exam',
              date: dateTime,
              timeString: DateFormat('hh:mm a').format(dateTime),
              id: test.sId,
            ));
          }
        }
      }

      // Parse resources (if needed in the timeline)
      if (lesson.resources != null) {
        for (var resource in lesson.resources!) {
          if (resource.resourceDate != null) {
            final dateTime =
                TimeConverter.toDhakaTime(DateTime.parse(resource.resourceDate!));
            activities.add(RoutineActivity(
              type: 'Resource',
              title: resource.name ?? 'Resource',
              date: dateTime,
              timeString: DateFormat('hh:mm a').format(dateTime),
              id: resource.sId,
            ));
          }
        }
      }
    }

    // Sort activities by date
    activities.sort((a, b) => a.date.compareTo(b.date));
    return activities;
  }

  // Get activities for a specific day
  List<RoutineActivity> getActivitiesForDay(DateTime day) {
    final activities = state.value ?? [];
    return activities
        .where((activity) =>
            activity.date.year == day.year &&
            activity.date.month == day.month &&
            activity.date.day == day.day)
        .toList();
  }

  // Get upcoming activities from tomorrow onwards
  List<RoutineActivity> getUpcomingActivities() {
    final activities = state.value ?? [];
    var tomorrow = TimeConverter.nowInDhaka().add(const Duration(days: 1));
    tomorrow = DateTime(tomorrow.year, tomorrow.month,
        tomorrow.day); // Reset time to start of day

    return activities
        .where((activity) => activity.date.isAfter(tomorrow))
        .take(5) // Limit to 5 upcoming activities
        .toList();
  }

  // Get event types for a day (for colored dots)
  Map<String, bool> getEventTypesForDay(DateTime day) {
    final activitiesForDay = getActivitiesForDay(day);
    Map<String, bool> result = {
      'Class': false,
      'Assignment': false,
      'Exam': false,
      'Resource': false,
    };

    for (var activity in activitiesForDay) {
      result[activity.type] = true;
    }

    return result;
  }

  // Group upcoming activities by date
  Map<String, List<RoutineActivity>> getGroupedUpcomingActivities() {
    final activities = getUpcomingActivities();
    final Map<String, List<RoutineActivity>> groupedActivities = {};

    for (var activity in activities) {
      final dateStr = DateFormat('EEEE , MMMM d, yyyy').format(activity.date);
      if (!groupedActivities.containsKey(dateStr)) {
        groupedActivities[dateStr] = [];
      }
      groupedActivities[dateStr]!.add(activity);
    }

    return groupedActivities;
  }
}
