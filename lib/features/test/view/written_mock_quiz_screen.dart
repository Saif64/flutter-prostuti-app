import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:prostuti/common/widgets/common_widgets/common_widgets.dart';
import 'package:prostuti/common/widgets/long_button.dart';
import 'package:prostuti/core/configs/app_colors.dart';
import 'package:prostuti/core/services/localization_service.dart';
import 'package:prostuti/features/test/model/mock_written_quiz_model.dart';
import 'package:prostuti/features/test/repository/mock_test_repo.dart';
import 'package:prostuti/features/test/view/written_mock_quiz_history_screen.dart';
import '../../../core/services/debouncer.dart';
import '../../../core/services/nav.dart';
import '../../../core/services/timer.dart';
import '../../course/materials/test/widgets/countdown_timer.dart';
import '../widgets/written_quiz_question_widget.dart';

class WrittenMockQuizScreen extends ConsumerStatefulWidget {
  final MockWrittenQuizResponse mockQuiz;
  final bool isSegmentTest;

  const WrittenMockQuizScreen({
    super.key,
    required this.mockQuiz,
    this.isSegmentTest = false,
  });

  @override
  ConsumerState<WrittenMockQuizScreen> createState() =>
      _WrittenMockQuizScreenState();
}

class _WrittenMockQuizScreenState extends ConsumerState<WrittenMockQuizScreen>
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

  void updateAnswer(String questionId, String answer) {
    final index =
        answerList.indexWhere((item) => item["question_id"] == questionId);
    if (index != -1) {
      setState(() {
        answerList[index]["selectedOption"] = answer;
      });
    }
  }

  void _startTimer() {
    if (remainingTime <= 0) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          remainingTime--;
        });
        if (remainingTime == 0) {
          _submitAnswers();
        } else {
          _startTimer();
        }
      }
    });
  }

  Future<void> _submitAnswers() async {
    _debouncer.run(
      action: () async {
        print(answerList);
        ref.read(countdownProvider.notifier).stopTimer();

        final remainingTime = ref.read(countdownProvider).remainingTime.inSeconds;
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
            WrittenMockQuizHistoryScreen(quizId: widget.mockQuiz.data!.id!),
          ),
        );
      },
      loadingController: ref.read(_loadingProvider.notifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: commonAppbar(context.l10n?.mockTest ?? "Written Mock Test"),
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
                            color: AppColors.borderFocusPrimaryLight,
                          )),
                      Text(" ${widget.mockQuiz.data?.questionType}",
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.borderFocusPrimaryLight,
                          )),
                    ],
                  ),
                  const Gap(8),
                  Text(
                    "প্রতিটি প্রশ্নে 1 পয়েন্ট থাকে এবং প্রতিটি ভুল উত্তরের জন্য \n0.5 পয়েন্ট কাটা হবে।",
                    style: theme.textTheme.bodyMedium,
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
                  return WrittenQuizQuestionWidget(
                    questionNumber: index + 1,
                    theme: theme,
                    questionList: widget.mockQuiz.data!.questions![index],
                    onAnswerChange: updateAnswer,
                  );
                },
              ),
            ),
            const Gap(12),
            LongButton(
              onPressed: _submitAnswers,
              text: "Submit Test",
            ),
            const Gap(12),
          ],
        ),
      ),
    );
  }
}
