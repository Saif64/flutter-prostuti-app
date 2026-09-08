import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:prostuti/common/widgets/common_widgets/common_widgets.dart';
import 'package:prostuti/common/widgets/long_button.dart';
import 'package:prostuti/core/configs/app_colors.dart';
import 'package:prostuti/core/services/localization_service.dart';
import 'package:prostuti/features/test/repository/mock_test_repo.dart';
import 'package:prostuti/features/test/view/written_mock_quiz_history_screen.dart';
import '../../../core/services/debouncer.dart';
import '../../../core/services/nav.dart';
import '../../../core/services/timer.dart';
import '../../course/materials/test/viewmodel/mcq_test_details_viewmodel.dart';
import '../../course/materials/test/widgets/build_mcq_question_item.dart';
import '../../course/materials/test/widgets/countdown_timer.dart';
import '../model/mock_quiz_model.dart';
import '../widgets/omr_sheet_widget.dart';
import 'mcq_quiz_result_screen.dart';

class MCQMockQuizScreen extends ConsumerStatefulWidget {
  final MockQuizResponse mockQuiz;
  final bool isSegmentTest;

  const MCQMockQuizScreen({
    super.key,
    required this.mockQuiz,
    this.isSegmentTest = false,
  });

  @override
  ConsumerState<MCQMockQuizScreen> createState() => _MCQMockQuizScreenState();
}

class _MCQMockQuizScreenState extends ConsumerState<MCQMockQuizScreen>
    with CommonWidgets {
  final Map<int, int?> selectedAnswers = {};
  final List<Map<String, dynamic>> answerList = [];
  late int remainingTime;
  late final int totalQuestions;
  final _debouncer = Debouncer(milliseconds: 120);
  final _loadingProvider = StateProvider<bool>((ref) => false);

  @override
  void initState() {
    super.initState();
    remainingTime = widget.mockQuiz.data?.time ?? 0;
    totalQuestions = widget.mockQuiz.data?.questions!.length ?? 0;

    final questions = widget.mockQuiz.data?.questions ?? [];
    answerList.clear();
    for (var question in questions) {
      answerList.add({
        "question_id": question.sId,
        "selectedOption": "null",
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize and start the countdown timer
      final duration = Duration(minutes: remainingTime);
      ref.read(countdownProvider.notifier).initialize(duration);
      ref.read(countdownProvider.notifier).startTimer();
    });
  }

  Future<void> _submitAnswers() async {
    _debouncer.run(
      action: () async {
        print(answerList);
        ref.read(countdownProvider.notifier).stopTimer();

        final remainingTime =
            ref.read(countdownProvider).remainingTime.inSeconds;
        final totalTime = widget.mockQuiz.data!.time!.toInt() * 60;
        final timeTaken = totalTime - remainingTime;

        final payload = {
          "answers": answerList,
        };

        final response = await ref.read(mockTestRepoProvider).submitMockQuiz(
              quizId: widget.mockQuiz.data!.id!,
              payload: payload,
              isSegmentTest: widget.isSegmentTest,
            );

        response.fold(
            (l) => Fluttertoast.showToast(msg: l.message),
            (testResult) => Nav().pushReplacement(
                  MCQMockQuizHistoryScreen(
                    quizId: widget.mockQuiz.data!.id!,
                  ),
                ));
      },
      loadingController: ref.read(_loadingProvider.notifier),
    );
  }

  void _showOMRSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return OMRSheetWidget(
              totalQuestions: widget.mockQuiz.data!.questions!.length,
              selectedAnswers: selectedAnswers,
              onAnswerSelected: (questionNumber, optionIndex) {
                setState(() {
                  selectedAnswers[questionNumber] = optionIndex;
                  final answerIndex = answerList.indexWhere(
                    (answer) =>
                        answer['question_id'] ==
                        widget
                            .mockQuiz.data!.questions![questionNumber - 1].sId,
                  );

                  if (answerIndex != -1) {
                    answerList[answerIndex]['selectedOption'] = widget
                        .mockQuiz
                        .data!
                        .questions![questionNumber - 1]
                        .options![optionIndex];
                  }
                });
              },
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: commonAppbar(context.l10n?.mockTest ?? "MCQ Mock Test"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Info Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.onSecondary,
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("টেস্ট টাইপ :",
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          )),
                      Text(" ${widget.mockQuiz.data?.questionType}",
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          )),
                    ],
                  ),
                  const Gap(8),
                  Text(
                    "প্রতিটি প্রশ্নে 1 পয়েন্ট থাকে এবং প্রতিটি ভুল উত্তরের জন্য \n0.5 পয়েন্ট কাটা হবে।",
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: Theme.of(context).colorScheme.surface),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Gap(16),
            CountdownTimer(
              onTimeUp: _submitAnswers,
            ),
            const Gap(16),
            // Questions List
            Expanded(
              child: ListView.builder(
                itemCount: widget.mockQuiz.data?.questions!.length,
                itemBuilder: (context, index) {
                  return MCQQuestionWidget(
                    questionNumber: index + 1,
                    theme: theme,
                    questionList: widget.mockQuiz.data!.questions![index],
                    selectedAnswers: selectedAnswers,
                    answerList: answerList,
                    isTestify: true,
                  );
                },
              ),
            ),
            const Gap(12),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.shadePrimaryLight,
                      minimumSize: Size(width * .45, 54),
                      maximumSize: Size(width * .45, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(
                          color: AppColors.backgroundActionPrimaryLight,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 13, horizontal: 23)),
                  onPressed: _showOMRSheet,
                  child: Text(
                    "OMR দেখুন",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.backgroundActionPrimaryLight,
                        ),
                  ),
                ),
                const Gap(12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backgroundActionPrimaryLight,
                      minimumSize: Size(width * .45, 54),
                      maximumSize: Size(width * .45, 54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 13, horizontal: 23)),
                  onPressed: _submitAnswers,
                  child: Text(
                    "সাবমিট করুন",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
            const Gap(12),
          ],
        ),
      ),
    );
  }
}
