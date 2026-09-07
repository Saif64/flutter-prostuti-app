import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prostuti/common/widgets/common_widgets/common_widgets.dart';
import 'package:prostuti/features/course/materials/test/view/mcq_test_details_view.dart';
import 'package:prostuti/features/course/materials/test/view/opps_view.dart';
import 'package:prostuti/features/course/materials/test/view/written_mock_test_history_view.dart';
import 'package:prostuti/features/course/materials/test/view/written_test_details_view.dart';
import 'package:prostuti/features/course/materials/test/viewmodel/get_test_by_id.dart';
import 'package:prostuti/features/course/materials/test/viewmodel/test_viewmodel.dart';

import '../../../../../common/widgets/time_converter.dart';
import '../../../../../core/services/nav.dart';
import '../../../course_list/viewmodel/get_course_by_id.dart';
import '../../get_material_completion.dart';
import '../../shared/widgets/material_list_skeleton.dart';
import '../../shared/widgets/trailing_icon.dart';
import '../viewmodel/written_test_viewmodel.dart';
import 'mcq_test_history_view.dart';

class TestListView extends ConsumerStatefulWidget {
  const TestListView({super.key});

  @override
  TestListViewState createState() => TestListViewState();
}

class TestListViewState extends ConsumerState<TestListView>
    with CommonWidgets, SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final courseId = ref.read(getCourseByIdProvider);
    ref.invalidate(completedIdProvider(courseId));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mcqTestAsync = ref.watch(mCQTestListViewmodelProvider);
    final writtenTestAsync = ref.watch(writtenTestListViewmodelProvider);
    final courseId = ref.read(getCourseByIdProvider);
    final completedAsync = ref.watch(completedIdProvider(courseId));

    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("টেস্ট"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "এমসিকিউ"),
            Tab(text: "রিটেন"),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorWeight: 2.0,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // MCQ ListView
          mcqTestAsync.when(
            data: (test) {
              return completedAsync.when(
                data: (completedId) {
                  final completedSet = Set<String>.from(completedId);
                  return ListView.builder(
                    itemCount: test.length,
                    itemBuilder: (context, index) {
                      final isCompleted =
                          completedSet.contains(test[index].sId);

                      return InkWell(
                        onTap: isUnlocked(test[index].publishDate!)
                            ? () async {
                                print(test[index].sId!);
                                ref
                                    .watch(getTestByIdProvider.notifier)
                                    .setTestId(test[index].sId!);

                                // final testHistory = await ref
                                //     .read(testRepoProvider)
                                //     .hasMCQTestGiven(test[index].sId!);

                                // bool canAccessTest = Func.canAccessContent(
                                //     test[index].publishDate!,
                                //     test[index].time!);
                                final bool canAccessTest =
                                    isToday(test[index].publishDate!);

                                if (isCompleted) {
                                  Nav().push(const MCQMockTestHistoryScreen());
                                } else {
                                  // if (canAccessTest) {
                                    Nav().push(const MCQTestDetailsView());
                                  /*} else {
                                    Nav().push(TestMissedView(
                                      testName: test[index].name!,
                                    ));
                                  }*/
                                }
                              }
                            : () {},
                        child: lessonItem(
                          theme,
                          trailingIcon: TrailingIcon(
                            classDate: test[index].publishDate!,
                            isCompleted: isCompleted,
                          ),
                          itemName: "টেস্ট: ${test[index].name}",
                          icon: "assets/icons/test.svg",
                          lessonName: '${test[index].lessonId!.number} ',
                        ),
                      );
                    },
                  );
                },
                error: (error, stackTrace) => Center(
                  child: Text(error.toString()),
                ),
                loading: () => MaterialListSkeleton(),
              );
            },
            error: (error, stackTrace)  {
              print("Error : $error");
              print("stackTrace : $stackTrace");
              return Text("$error");

            } ,
            loading: () => MaterialListSkeleton(),
          ),
          // Written ListView
          writtenTestAsync.when(
            data: (test) {
              return completedAsync.when(
                data: (completedId) {
                  final completedSet = Set<String>.from(completedId);
                  return ListView.builder(
                    itemCount: test.length,
                    itemBuilder: (context, index) {
                      final isCompleted =
                          completedSet.contains(test[index].sId);
                      return InkWell(
                        onTap: isUnlocked(test[index].publishDate!)
                            ? () {
                                ref
                                    .watch(getTestByIdProvider.notifier)
                                    .setTestId(test[index].sId!);

                                final bool canAccessTest =
                                isToday(test[index].publishDate!);

                                if (isCompleted) {
                                  Nav().push(const WrittenMockTestHistoryScreen());
                                } else {
                                  // if (canAccessTest) {
                                  Nav().push(const WrittenTestDetailsView());
                                  /*} else {
                                    Nav().push(TestMissedView(
                                      testName: test[index].name!,
                                    ));
                                  }*/
                                }
                              }
                            : () {},
                        child: lessonItem(
                          theme,
                          trailingIcon: TrailingIcon(
                            classDate: test[index].publishDate!,
                            isCompleted: isCompleted,
                          ),
                          itemName: "টেস্ট: ${test[index].name}",
                          icon: "assets/icons/test.svg",
                          lessonName: '${test[index].lessonId!.number} ',
                        ),
                      );
                    },
                  );
                },
                error: (error, stackTrace) {
                  return Center(
                    child: Text(error.toString()),
                  );
                },
                loading: () => MaterialListSkeleton(),
              );
            },
            error: (error, stackTrace) {
              print("Error : $error");
              print("stackTrace : $stackTrace");
              return Text("$error");

    } ,
            loading: () => MaterialListSkeleton(),
          ),
        ],
      ),
    );
  }

  bool isUnlocked(String s) {
    return TimeConverter.isUnlockedInDhaka(s);
  }

  bool isToday(String s) {
    return TimeConverter.isTodayInDhaka(s);
  }
}
