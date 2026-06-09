import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/models.dart';
import '../../shared/services/services.dart';
import '../../shared/strings.dart';
import '../../shared/theme/theme.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/choice_tile.dart';

/// Quick five-question quiz. Loads the question bank, picks a random subset,
/// reveals answers inline, surfaces a fun fact per question in a dialog, and
/// ends on an animated score reveal. Game state is local to this screen.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  static const int _perGame = 5;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _rng = Random();

  List<QuizQuestion>? _questions;
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _finished = false;

  void _restart() {
    final pool = ref.read(quizQuestionsProvider).value;
    setState(() {
      if (pool != null && pool.isNotEmpty) _questions = _selectFrom(pool);
      _index = 0;
      _score = 0;
      _selected = null;
      _finished = false;
    });
  }

  void _answer(int choice, QuizQuestion question) {
    if (_selected != null) return;
    setState(() {
      _selected = choice;
      if (choice == question.correctIndex) _score++;
    });
  }

  Future<void> _next(QuizQuestion question) async {
    await _showFunFact(question.funFact);
    if (!mounted) return;
    final isLast = _index == _questions!.length - 1;
    setState(() {
      if (isLast) {
        _finished = true;
      } else {
        _index++;
        _selected = null;
      }
    });
  }

  Future<void> _showFunFact(String fact) {
    return showDialog<void>(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.6),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.lightbulb_rounded,
              color: AppColors.warning,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(AppStrings.funFact, style: AppTextStyles.titleMedium),
          ],
        ),
        content: Text(fact, style: AppTextStyles.bodySecondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.continueLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(quizQuestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.quiz)),
      body: SafeArea(
        child: questionsAsync.when(
          data: (pool) {
            if (pool.isEmpty) {
              return const EmptyState(
                icon: Icons.quiz_outlined,
                title: AppStrings.quizEmptyTitle,
                message: AppStrings.quizEmptyBody,
              );
            }
            _questions ??= _selectFrom(pool);
            if (_finished) {
              return _Results(
                score: _score,
                total: _questions!.length,
                onPlayAgain: _restart,
                onHome: () => context.pop(),
              );
            }
            return _Game(
              question: _questions![_index],
              index: _index,
              total: _questions!.length,
              selected: _selected,
              onAnswer: _answer,
              onNext: _next,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Text(
              AppStrings.genericError,
              style: AppTextStyles.bodySecondary,
            ),
          ),
        ),
      ),
    );
  }

  List<QuizQuestion> _selectFrom(List<QuizQuestion> pool) {
    final shuffled = pool.toList()..shuffle(_rng);
    return shuffled.take(min(QuizScreen._perGame, pool.length)).toList();
  }
}

class _Game extends StatelessWidget {
  const _Game({
    required this.question,
    required this.index,
    required this.total,
    required this.selected,
    required this.onAnswer,
    required this.onNext,
  });

  final QuizQuestion question;
  final int index;
  final int total;
  final int? selected;
  final void Function(int choice, QuizQuestion q) onAnswer;
  final Future<void> Function(QuizQuestion q) onNext;

  ChoiceState _stateFor(int i) {
    if (selected == null) return ChoiceState.idle;
    if (i == question.correctIndex) return ChoiceState.correct;
    if (i == selected) return ChoiceState.wrong;
    return ChoiceState.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    final answered = selected != null;
    final isLast = index == total - 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.questionProgress(index + 1, total),
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: LinearProgressIndicator(
                  value: (index + 1) / total,
                  minHeight: 6,
                  backgroundColor: AppColors.surface,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(question.question, style: AppTextStyles.titleLarge),
                const SizedBox(height: AppSpacing.lg),
                for (var i = 0; i < question.choices.length; i++) ...[
                  ChoiceTile(
                    label: question.choices[i],
                    state: _stateFor(i),
                    onTap: answered ? null : () => onAnswer(i, question),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: PrimaryButton(
            label: isLast ? AppStrings.seeResults : AppStrings.nextQuestion,
            onPressed: answered ? () => onNext(question) : null,
          ),
        ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.score,
    required this.total,
    required this.onPlayAgain,
    required this.onHome,
  });

  final int score;
  final int total;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
            duration: const Duration(milliseconds: 480),
            curve: Curves.easeOutBack,
            builder: (context, t, child) =>
                Transform.scale(scale: t, child: child),
            child: Column(
              children: [
                Text(
                  AppStrings.quizCompleteTitle,
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  AppStrings.quizScore(score, total),
                  style: AppTextStyles.balanceHero.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: AppStrings.playAgain,
            icon: Icons.refresh_rounded,
            onPressed: onPlayAgain,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onHome,
            child: const Text(AppStrings.backToDashboard),
          ),
        ],
      ),
    );
  }
}
