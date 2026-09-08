import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:prostuti/common/widgets/long_button.dart';
import 'package:prostuti/core/services/localization_service.dart';
import 'package:prostuti/features/auth/login/view/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentIndex < 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        PageView(
          controller: _pageController,
          reverse: false,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    'assets/images/onboarding_image1.png',
                    height: 180,
                    width: 270,
                    fit: BoxFit.contain,
                  ),
                ),
                // Add your images to assets folder
                const Gap(50),
                Text(
                  "প্রস্তুতির নতুন অধ্যায়ে স্বাগতম!",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Gap(16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "প্রস্তুতি অ্যাপে স্বাগতম! অনুশীলন করুন, দক্ষতা গড়ুন, আত্মবিশ্বাস বাড়ান। আপনার সাফল্যের যাত্রা শুরু হোক আজ থেকেই!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    'assets/images/onboarding_image2.png',
                    height: 180,
                    width: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                // Add your images to assets folder
                const Gap(50),
                Text(
                  "শেখার সুবিধা",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Gap(16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "ইন্টারঅ্যাকটিভ ফ্ল্যাশকার্ড, কুইজ এবং ডাউট সলভের মাধ্যমে সহজে শেখার অভিজ্ঞতা নিন।",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 180, // Adjust position for indicators
          left: 0,
          right: 0,
          child: Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: 2, // Number of pages
              effect: const ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.blue,
                dotColor: Colors.grey,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LongButton(
                onPressed: () async {
                  final onboardingService = ref.read(onboardingServiceProvider);
                  await onboardingService.setOnboardingComplete();

                  // Navigate to login
                  if (mounted) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const LoginView(),
                    ));
                  }
                },
                text: context.l10n!.getStarted),
          ),
        ),
      ]),
    );
  }
}

class OnboardingService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  // Check if the user has seen onboarding
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  // Mark onboarding as completed
  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }

  // Reset onboarding status (for testing)
  Future<void> resetOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, false);
  }
}

// Provider for OnboardingService
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

// Provider for checking onboarding status
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final onboardingService = ref.watch(onboardingServiceProvider);
  return onboardingService.hasSeenOnboarding();
});
