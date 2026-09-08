import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:prostuti/features/course/materials/test/model/written_test_model.dart';
import '../model/favorite_question_model.dart';
import '../viewmodel/favorite_question_viewmodel.dart';
import '../../../core/services/localization_service.dart';
import '../widgets/build_fav_mcq_question_item.dart';
import '../widgets/build_fav_written_question_item.dart';

class FavoriteQuestionsView extends ConsumerWidget {
  const FavoriteQuestionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(favoriteQuestionsProvider);

    return questionsAsync.when(
      data: (questions) {
        if (questions.isEmpty) {
          return const Center(
            child: Text("No favorite questions added yet"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            return FavoriteQuestionItem(
              question: question,
              index: index,
            );
          },
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          semanticsLabel: context.l10n!.loading,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      error: (error, stack) {
        print("error : $error");
        print("stack : $stack");
        return Center(
          child: Text('${context.l10n!.error}: ${error.toString()}'),
        );
      }
    );
  }
}

class FavoriteQuestionItem extends ConsumerWidget {
  final FavouriteQuestions question;
  final int index;

  const FavoriteQuestionItem({
    required this.question,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Question type badge
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: question.type == "MCQ" ? Colors.blue : Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              question.type == "MCQ" ? "MCQ" : "Written",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),

        const Gap(8),

        // Question content
        if (question.type == "MCQ")
          _buildMCQQuestion(context)
        else
          _buildWrittenQuestion(context),

       /* // Favorite toggle button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.favorite, color: Colors.red),
            label: Text(context.l10n!.removeFromFavorites),
            onPressed: () {
              ref.read(favoriteQuestionsProvider.notifier)
                  .toggleFavorite(question.sId!);
            },
          ),
        ),*/

        const Divider(),
        const Gap(16),
      ],
    );
  }

  Widget _buildMCQQuestion(BuildContext context) {
    // Convert to MCQ QuestionList format for MCQQuestionWidget
    final mcqQuestionList = _convertToMCQQuestionList();

    return FavoriteMCQQuestionWidget(
      questionNumber: index + 1,
      theme: Theme.of(context),
      questionList: mcqQuestionList,
      answerList: [], // View-only mode
    );
  }

  Widget _buildWrittenQuestion(BuildContext context) {
    // Convert to Written QuestionList format for WrittenQuestionWidget
    final writtenQuestionList = _convertToWrittenQuestionList();

    return FavoriteWrittenQuestionWidget(
      questionNumber: index + 1,
      theme: Theme.of(context),
      questionList: writtenQuestionList,
    );
  }

  // Simple conversion functions instead of using adapters
  dynamic _convertToMCQQuestionList() {
    // Create the QuestionList format needed by MCQQuestionWidget
    return QuestionList(
      sId: question.sId,
      title: question.title,
      description: question.description,
      hasImage: question.hasImage,
      image: question.image,
      options: question.options,
      correctOption: question.correctOption,
    );
  }

  dynamic _convertToWrittenQuestionList() {
    // Create the QuestionList format needed by WrittenQuestionWidget
    return QuestionList(
      sId: question.sId,
      title: question.title,
      description: question.description,
      hasImage: question.hasImage,
      image: question.image,
    );
  }
}
class QuestionList {
  final String? sId;
  final String? title;
  final String? description;
  final bool? hasImage;
  final QuizImage? image;
  final List<dynamic>? options;
  final String? correctOption;

  QuestionList({
    this.sId,
    this.title,
    this.description,
    this.hasImage,
    this.image,
    this.options,
    this.correctOption,
  });
}
