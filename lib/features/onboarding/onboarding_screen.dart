import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../shared/services/services.dart';
import '../../shared/strings.dart';
import '../../shared/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

class _Slide {
  const _Slide({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}

const List<_Slide> _slides = [
  _Slide(
    icon: Icons.insights_rounded,
    title: AppStrings.onboardTitle1,
    body: AppStrings.onboardBody1,
  ),
  _Slide(
    icon: Icons.bolt_rounded,
    title: AppStrings.onboardTitle2,
    body: AppStrings.onboardBody2,
  ),
  _Slide(
    icon: Icons.school_rounded,
    title: AppStrings.onboardTitle3,
    body: AppStrings.onboardBody3,
  ),
];

/// Swipeable first-run intro. Marks onboarding as seen on completion/skip so it
/// never shows again, then routes to sign-in.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(prefsServiceProvider).setOnboardingSeen(true);
    if (mounted) context.go(AppRoutes.signIn);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: AppDurations.medium,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      // Shift the bloom with the page so the backdrop feels alive as you swipe.
      bloomAlignment: Alignment(-0.6 + _page * 0.6, -0.7),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text(AppStrings.skip),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _PageDots(count: _slides.length, active: _page),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: _isLast
                          ? AppStrings.getStarted
                          : AppStrings.continueLabel,
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 44, color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            slide.title,
            style: AppTextStyles.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            slide.body,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Animated page indicator — the active dot stretches into a pill. Width-only
/// change on a small element; cheap and reads as "you are here".
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});
  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: AppDurations.short,
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : AppColors.textTertiary,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
        );
      }),
    );
  }
}
