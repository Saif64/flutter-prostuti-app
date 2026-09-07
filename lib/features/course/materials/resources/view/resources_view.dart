import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prostuti/common/widgets/common_widgets/common_widgets.dart';
import 'package:prostuti/features/course/materials/resources/view/resource_details_view.dart';
import 'package:prostuti/features/course/materials/resources/viewmodel/get_resource_by_id.dart';

import '../../../../../common/widgets/time_converter.dart';
import '../../../course_details/viewmodel/course_details_vm.dart';
import '../../../course_list/viewmodel/get_course_by_id.dart';
import '../../get_material_completion.dart';
import '../../shared/widgets/material_list_skeleton.dart';
import '../../shared/widgets/trailing_icon.dart';

class ResourcesView extends ConsumerStatefulWidget {
  const ResourcesView({super.key});

  @override
  ResourcesViewState createState() => ResourcesViewState();
}

class ResourcesViewState extends ConsumerState<ResourcesView>
    with CommonWidgets {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final courseDetailsAsync = ref.watch(courseDetailsViewmodelProvider);
    final courseId = ref.read(getCourseByIdProvider);
    final completedAsync = ref.watch(completedIdProvider(courseId));

    return Scaffold(
      appBar: commonAppbar("রিসোর্স"),
      body: courseDetailsAsync.when(
        data: (courseDetails) {
          return completedAsync.when(
            data: (completedId) {
              final completedSet = Set<String>.from(completedId);
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        for (int i = 0;
                            i < (courseDetails.data!.lessons!.length);
                            i++)
                          if (courseDetails.data!.lessons!.isNotEmpty)
                            ListTileTheme(
                              contentPadding: const EdgeInsets.all(0),
                              dense: true,
                              horizontalTitleGap: 0.0,
                              minLeadingWidth: 0,
                              child: ExpansionTile(
                                title: lessonName(theme,
                                    '${courseDetails.data!.lessons![i].name} ${i + 1} '),
                                children: [
                                  for (int j = 0;
                                      j <
                                          courseDetails.data!.lessons![i]
                                              .resources!.length;
                                      j++)
                                    InkWell(
                                      onTap: () {
                                        final resourceDate = courseDetails
                                            .data!
                                            .lessons![i]
                                            .resources![j]
                                            .resourceDate!;
                                        if (TimeConverter.isUnlockedInDhaka(
                                            resourceDate)) {
                                          ref
                                              .watch(getResourceByIdProvider
                                                  .notifier)
                                              .setResourceId(courseDetails
                                                  .data!
                                                  .lessons![i]
                                                  .resources![j]
                                                  .sId!);

                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  ResourceDetailsView(
                                                isCompleted:
                                                    completedSet.contains(
                                                  courseDetails
                                                      .data!
                                                      .lessons![i]
                                                      .resources![j]
                                                      .sId,
                                                ),
                                              ),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(0.0,
                                                    1.0); // Start off-screen at the bottom
                                                const end = Offset
                                                    .zero; // End at its original position
                                                const curve = Curves
                                                    .easeInOut; // Smooth easing curve

                                                final tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));
                                                final offsetAnimation =
                                                    animation.drive(tween);

                                                return SlideTransition(
                                                  position: offsetAnimation,
                                                  child: child,
                                                );
                                              },
                                              transitionDuration: const Duration(
                                                  milliseconds:
                                                      300), // Animation duration
                                            ),
                                          ).then(
                                            (value) {
                                              if (value ?? false) {
                                                ref.refresh(completedIdProvider(
                                                    courseId));
                                              }
                                            },
                                          );
                                        }
                                      },
                                      child: materialItem(
                                        theme,
                                        trailingIcon: TrailingIcon(
                                          classDate: courseDetails
                                              .data!
                                              .lessons![i]
                                              .resources![j]
                                              .resourceDate!,
                                          isCompleted: completedSet.contains(
                                              courseDetails.data!.lessons![i]
                                                  .resources![j].sId),
                                        ),
                                        itemName:
                                            "${courseDetails.data!.lessons![i].resources![j].name}",
                                        icon: "assets/icons/resource.svg",
                                      ),
                                    ),
                                ],
                              ),
                            ),
                      ],
                    )),
              );
            },
            error: (error, stackTrace) => const Icon(
              Icons.dangerous,
              color: Colors.red,
            ),
            loading: () => MaterialListSkeleton(),
          );
        },
        error: (error, stackTrace) {
          return Text("$error");
        },
        loading: () {
          return MaterialListSkeleton();
        },
      ),
    );
  }
}
