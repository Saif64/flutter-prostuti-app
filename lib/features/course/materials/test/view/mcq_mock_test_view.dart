import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:prostuti/common/widgets/long_button.dart';
import 'package:prostuti/features/course/materials/test/view/test_result_view.dart';
import 'package:prostuti/features/course/materials/test/viewmodel/get_test_by_id.dart';

import '../../../../../common/widgets/common_widgets/common_widgets.dart';
import '../../../../../core/configs/app_colors.dart';
import '../../../../../core/services/debouncer.dart';
import '../../../../../core/services/nav.dart';
import '../../../../../core/services/timer.dart';
import '../../../course_list/viewmodel/get_course_by_id.dart';
import '../../../enrolled_course_landing/repository/enrolled_course_landing_repo.dart';
import '../../get_material_completion.dart';
import '../repository/test_repo.dart';
import '../viewmodel/mcq_test_details_viewmodel.dart';
import '../widgets/build_mcq_question_item.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/mcq_mock_test_skeleton.dart';

class MCQMockTestScreen extends ConsumerStatefulWidget {
  const MCQMockTestScreen({Key? key}) : super(key: key);

  @override
  MockTestScreenState createState() => MockTestScreenState();
}

class MockTestScreenState extends ConsumerState<MCQMockTestScreen>
    with CommonWidgets {
  final Map<int, int?> selectedAnswers = {};
  final List<Map<String, dynamic>> answerList = [];
  final _debouncer = Debouncer(milliseconds: 120);
  final _loadingProvider = StateProvider<bool>((ref) => false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final testDetails = ref.read(mCQTestDetailsViewmodelProvider);
      testDetails.whenData((test) {
        // Pre-populate answerList
        for (var question in test.data!.questionList!) {
          answerList.add({
            "question_id": question.sId,
            "selectedOption": "null",
          });
        }

        // Initialize and start the countdown timer
        final duration = Duration(minutes: test.data!.time!.toInt());
        ref.read(countdownProvider.notifier).initialize(duration);
        ref.read(countdownProvider.notifier).startTimer();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final mCQTestDetailsAsync = ref.watch(mCQTestDetailsViewmodelProvider);
    final isLoading = ref.watch(_loadingProvider);

    return Scaffold(
      appBar: commonAppbar("মক টেস্ট"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: mCQTestDetailsAsync.when(
          data: (test) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Test Info Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.shadeSecondaryLight,
                    border:
                    Border.all(color: AppColors.borderFocusPrimaryLight),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "বিষয় :",
                            style: theme.textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.borderFocusPrimaryLight),
                          ),
                          Text(
                            "${test.data!.name}",
                            style: theme.textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.borderFocusPrimaryLight),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "টেস্ট টাইপ :",
                            style: theme.textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.borderFocusPrimaryLight),
                          ),
                          Text(
                            "${test.data!.type}",
                            style: theme.textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.borderFocusPrimaryLight),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        "প্রতিটি প্রশ্নে 1 পয়েন্ট থাকে এবং প্রতিটি ভুল উত্তরের জন্য \n0.5 পয়েন্ট কাটা হবে।",
                        style: theme.textTheme.bodyMedium!.copyWith(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                CountdownTimer(onTimeUp: () {
                  _submitTest(test);
                },),
                const Gap(24),
                // Questions Section
                Expanded(
                  child: ListView.builder(
                    itemCount: test.data!.questionList!.length,
                    itemBuilder: (context, index) {
                      return MCQQuestionWidget(
                        questionNumber: index + 1,
                        theme: theme,
                        questionList: test.data!.questionList![index],
                        selectedAnswers: selectedAnswers,
                        answerList: answerList,
                        isTestify: false,
                      );
                    },
                  ),
                ),
                // Submit Button
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : LongButton(
                  onPressed: () {
                    if (answerList.any(
                            (answer) => answer['selectedOption'] != "null")) {
                      _submitTest(test);
                    } else {
                      Fluttertoast.showToast(
                        msg: "You need to submit at least 1 answer.",
                      );
                    }
                  },
                  text: "সাবমিট করুন",
                ),
              ],
            );
          },
          error: (error, stackTrace) {
            print(error);
            print(stackTrace);
          },
          loading: () => const MockQuestionSkeleton(),
        ),
      ),
    );
  }

  Future<void> _submitTest(dynamic test) async {
    _debouncer.run(
      action: () async {
        print(answerList);
        ref.read(countdownProvider.notifier).stopTimer();

        final remainingTime =
            ref
                .read(countdownProvider)
                .remainingTime
                .inSeconds;
        final totalTime = test.data!.time!.toInt() * 60;
        final timeTaken = totalTime - remainingTime;

        final payload = {
          "course_id": test.data!.courseId,
          "lesson_id": test.data!.lessonId!.sId,
          "test_id": test.data!.sId,
          "answers": answerList,
          "timeTaken": timeTaken,
        };

        final response =
        await ref.read(testRepoProvider).submitMCQTest(payload: payload);

        response.fold(
              (l) => Fluttertoast.showToast(msg: l.message),
              (testResult) => _navigateToResults(test, testResult, timeTaken),
        );
      },
      loadingController: ref.read(_loadingProvider.notifier),
    );
  }

  void _navigateToResults(dynamic test, dynamic testResult,
      int timeTaken) async {
    _debouncer.run(
      action: () async {
        final markAsComplete = await ref
            .read(enrolledCourseLandingRepoProvider)
            .markAsComplete({
          "materialType": "test",
          "material_id": ref.read(getTestByIdProvider)
        });

        if (markAsComplete) {

          final courseId = ref.read(getCourseByIdProvider);
          ref.invalidate(completedIdProvider(courseId));

          Nav().pushReplacement(
            TestResultScreen(
              resultData: {
                "testTitle": test.data!.name,
                "scorePercentage": ((testResult.data!.rightScore!.toInt() /
                    testResult.data!.totalScore!.toInt()) *
                    100)
                    .toInt(),
                "feedback": "চমৎকার",
                "pointsEarned": testResult.data!.score,
                "timeTaken": timeTaken,
                "correctAns": testResult.data!.rightScore,
                "wrongAns": testResult.data!.wrongScore,
                "skippedAns": testResult.data!.totalScore! -
                    (testResult.data!.rightScore!.toInt() +
                        testResult.data!.wrongScore!.toInt()),
              },
            ),
          );
        } else {
          Fluttertoast.showToast(
            msg: "Something went wrong. Please try again!",
          );
        };
      }, loadingController: ref.read(_loadingProvider.notifier),);
  }
}