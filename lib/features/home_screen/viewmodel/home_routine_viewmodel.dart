import 'package:intl/intl.dart';
import 'package:prostuti/features/course/course_details/repository/course_details_repo.dart';
import 'package:prostuti/features/course/my_course/model/my_course_model.dart';
import 'package:prostuti/features/course/my_course/repository/my_course_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/widgets/time_converter.dart';
import '../../course/course_details/model/course_details_model.dart';
import '../model/home_screen_model.dart';

part 'home_routine_viewmodel.g.dart';

@riverpod
class HomeRoutineViewModel extends _$HomeRoutineViewModel {
  @override
  Future<List<HomeRoutineActivity>> build() async {
    return await getTodayActivities();
  }

  Future<List<HomeRoutineActivity>> getTodayActivities() async {
    try {
      // Step 1: Get all enrolled courses
      final enrolledCoursesResponse =
          await ref.read(myCourseRepoProvider).getEnrolledCourseList();

      final enrolledCourses = enrolledCoursesResponse.fold(
        (l) => <EnrolledCourseListData>[],
        (courses) => courses.data?.data ?? <EnrolledCourseListData>[],
      );

      if (enrolledCourses.isEmpty) {
        return [];
      }

      // Step 2: Get today's activities for each course
      List<HomeRoutineActivity> allActivities = [];

      // To avoid too many simultaneous API calls, let's check one (or a few) courses only
      // We'll cycle through different courses on different app launches
      final courseDetailsRepo = ref.read(courseDetailsRepoProvider);

      // Get a single course for now to avoid overloading with API calls
      // In a production app, you might want to implement a caching mechanism
      if (enrolledCourses.isNotEmpty &&
          enrolledCourses[0].courseId?.sId != null) {
        try {
          final courseId = enrolledCourses[0].courseId!.sId!;
          final courseName =
              enrolledCourses[0].courseId!.name ?? "Unknown Course";

          // Use the existing course details repo
          final courseDetailsResponse =
              await courseDetailsRepo.getCourseDetails(courseId);

          courseDetailsResponse.fold(
            (l) {
              // Handle error
            },
            (courseDetails) {
              final todayActivities =
                  _parseActivitiesForToday(courseDetails, courseName);
              allActivities.addAll(todayActivities);
            },
          );
        } catch (e) {
          // Skip this course if there's an error
        }
      }

      // Step 3: Sort activities by time
      allActivities.sort((a, b) => a.time.compareTo(b.time));

      return allActivities;
    } catch (e) {
      throw Exception("Failed to load today's activities: $e");
    }
  }

  List<HomeRoutineActivity> _parseActivitiesForToday(
      CourseDetails courseDetails, String courseName) {
    List<HomeRoutineActivity> activities = [];
    final today = TimeConverter.nowInDhaka();
    // Built with DateTime.utc (not the local constructor) so it stays in the
    // same shifted-epoch domain as TimeConverter's Dhaka-time values and
    // compares correctly regardless of the device's own timezone.
    final startOfToday = DateTime.utc(today.year, today.month, today.day);
    final endOfToday = startOfToday
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    if (courseDetails.data?.lessons == null) return activities;

    for (var lesson in courseDetails.data!.lessons!) {
      // Parse recorded classes
      if (lesson.recodedClasses != null) {
        for (var recordedClass in lesson.recodedClasses!) {
          if (recordedClass.classDate != null) {
            final dateTime =
                TimeConverter.toDhakaTime(DateTime.parse(recordedClass.classDate!));
            if (dateTime.isAfter(startOfToday) &&
                dateTime.isBefore(endOfToday)) {
              activities.add(HomeRoutineActivity(
                type: 'Class',
                title: recordedClass.recodeClassName ?? 'Class',
                courseName: courseName,
                time: dateTime,
                timeString: DateFormat('hh:mm a').format(dateTime),
                details: recordedClass.classDetails,
                id: recordedClass.sId,
              ));
            }
          }
        }
      }

      // Parse assignments
      if (lesson.assignments != null) {
        for (var assignment in lesson.assignments!) {
          if (assignment.unlockDate != null) {
            final dateTime =
                TimeConverter.toDhakaTime(DateTime.parse(assignment.unlockDate!));
            if (dateTime.isAfter(startOfToday) &&
                dateTime.isBefore(endOfToday)) {
              activities.add(HomeRoutineActivity(
                type: 'Assignment',
                title: assignment.assignmentNo ?? 'Assignment',
                courseName: courseName,
                time: dateTime,
                timeString: DateFormat('hh:mm a').format(dateTime),
                details: assignment.details,
                id: assignment.sId,
              ));
            }
          }
        }
      }

      // Parse tests
      if (lesson.tests != null) {
        for (var test in lesson.tests!) {
          if (test.publishDate != null) {
            final dateTime =
                TimeConverter.toDhakaTime(DateTime.parse(test.publishDate!));
            if (dateTime.isAfter(startOfToday) &&
                dateTime.isBefore(endOfToday)) {
              activities.add(HomeRoutineActivity(
                type: 'Exam',
                title: test.name ?? 'Exam',
                courseName: courseName,
                time: dateTime,
                timeString: DateFormat('hh:mm a').format(dateTime),
                id: test.sId,
              ));
            }
          }
        }
      }

      // Parse resources (if needed in the timeline)
      if (lesson.resources != null) {
        for (var resource in lesson.resources!) {
          if (resource.resourceDate != null) {
            final dateTime =
                TimeConverter.toDhakaTime(DateTime.parse(resource.resourceDate!));
            if (dateTime.isAfter(startOfToday) &&
                dateTime.isBefore(endOfToday)) {
              activities.add(HomeRoutineActivity(
                type: 'Resource',
                title: resource.name ?? 'Resource',
                courseName: courseName,
                time: dateTime,
                timeString: DateFormat('hh:mm a').format(dateTime),
                id: resource.sId,
              ));
            }
          }
        }
      }
    }

    return activities;
  }
}
