import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:prostuti/common/helpers/theme_provider.dart';
import 'package:prostuti/core/services/localization_service.dart';
import 'package:prostuti/core/services/nav.dart';
import 'package:prostuti/features/chat/view/chat_view.dart';
import 'package:prostuti/features/course/course_list/view/course_list_view.dart';
import 'package:prostuti/features/course/my_course/view/my_course_view.dart';
import 'package:prostuti/features/home_screen/view/search_view.dart';
import 'package:prostuti/features/home_screen/widget/horizontal_flashcard_list_loading.dart';
import 'package:prostuti/features/leaderboard/widgets/leaderboard_section.dart';
import 'package:prostuti/features/test/view/test_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/configs/app_colors.dart';
import '../../auth/signup/widgets/flashcard_painter.dart';
import '../../flashcard/model/flashcard_model.dart';
import '../../flashcard/view/flashcard_study_view.dart';
import '../../flashcard/view/flashcard_view.dart';
import '../../flashcard/viewmodel/flashcard_viewmodel.dart';
import '../../notification/view/notification_view.dart';
import '../../notification/viewmodel/notification_badge_viewmodel.dart';
import '../../notification/widgets/notification_socket_listener.dart';
import '../../profile/view/profile_view.dart';
import '../../profile/viewmodel/profile_viewmodel.dart';
import '../widget/category_card.dart';
import '../widget/home_routine.dart';

final cachedUserProfileProvider = Provider.autoDispose((ref) {
  return ref.watch(userProfileProvider);
});

final hasLoadedProfileProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  final int? initialIndex;

  const HomeScreen({super.key, this.initialIndex});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _adController = PageController();
  int _currentIndex = 0;

  final _log = Logger();

  List<Color> flashCardColors = [
    AppColors.leaderboardSecondLight,
    AppColors.leaderboardFirstLight,
    AppColors.leaderboardThirdLight,
    AppColors.leaderboardSecondLight,
  ];
  int currentIndex = 0;
  List<bool> isShowingQuestionList = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != null) {
      _currentIndex = widget.initialIndex!;
      if (_currentIndex == 4) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(notificationBadgeCountProvider.notifier).reset();
        });
      }
    }
  }

  void _handleTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 4) {
      ref.read(notificationBadgeCountProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 0) {
      final hasLoaded = ref.read(hasLoadedProfileProvider);
      if (!hasLoaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(hasLoadedProfileProvider.notifier).state = true;
        });
      }
    }

    final unreadNotificationCount = ref.watch(notificationBadgeCountProvider);

    return NotificationSocketListener(
      child: Scaffold(
        body: _buildCurrentTab(),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _handleTabChange,
            elevation: 10,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            selectedItemColor: Theme.of(context).colorScheme.secondary,
            unselectedItemColor: AppColors.textTertiaryLight,
            showSelectedLabels: true,
            selectedLabelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor),
            unselectedLabelStyle: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiaryLight),
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  _currentIndex == 0
                      ? "assets/icons/bottom_nav_home_select.svg"
                      : "assets/icons/bottom_nav_home_unselect.svg",
                  colorFilter: ColorFilter.mode(
                      _currentIndex == 0
                          ? Theme.of(context).colorScheme.secondary
                          : AppColors.textTertiaryLight,
                      BlendMode.srcIn),
                ),
                label: "হোম",
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  _currentIndex == 1
                      ? "assets/icons/bottom_nav_flash_card_select.svg"
                      : "assets/icons/bottom_nav_flash_card_unselect.svg",
                  colorFilter: ColorFilter.mode(
                      _currentIndex == 1
                          ? Theme.of(context).colorScheme.secondary
                          : AppColors.textTertiaryLight,
                      BlendMode.srcATop),
                ),
                label: "ফ্ল্যাশ কার্ড",
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  _currentIndex == 2
                      ? "assets/icons/bottom_nav_chat_select.svg"
                      : "assets/icons/bottom_nav_chat_unselect.svg",
                  colorFilter: ColorFilter.mode(
                      _currentIndex == 2
                          ? Theme.of(context).colorScheme.secondary
                          : AppColors.textTertiaryLight,
                      BlendMode.srcIn),
                ),
                label: "ম্যাসেজ",
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  _currentIndex == 3
                      ? "assets/icons/bottom_nav_test_select.svg"
                      : "assets/icons/bottom_nav_test_unselect.svg",
                  colorFilter: ColorFilter.mode(
                      _currentIndex == 3
                          ? Theme.of(context).colorScheme.secondary
                          : AppColors.textTertiaryLight,
                      BlendMode.srcIn),
                ),
                label: "টেস্ট",
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: unreadNotificationCount > 0,
                  label: Text(
                    unreadNotificationCount > 9
                        ? '9+'
                        : '$unreadNotificationCount',
                  ),
                  child: SvgPicture.asset(
                    _currentIndex == 4
                        ? "assets/icons/bottom_nav_notification_select.svg"
                        : "assets/icons/bottom_nav_notification_unselect.svg",
                    colorFilter: ColorFilter.mode(
                        _currentIndex == 4
                            ? Theme.of(context).colorScheme.secondary
                            : AppColors.textTertiaryLight,
                        BlendMode.srcIn),
                  ),
                ),
                label: "নটিফিকেশন",
              ),
            ]),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const FlashcardView();
      case 2:
        return const ChatView();

      case 3:
        return TestLandingView();

      case 4:
        return const NotificationScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopSection(maxWidth).animate().fadeIn(duration: 575.ms),
              const Gap(16),
              _buildAdSection(maxWidth)
                  .animate()
                  .moveX(begin: 20, end: 0, duration: 500.ms),
              const Gap(16),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  context.l10n!.myCalendar,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ).animate().moveX(duration: 674.ms, curve: Curves.easeIn),
              const HomeRoutineWidget()
                  .animate()
                  .moveX(begin: 20, end: 0, duration: 500.ms),
              const Gap(16),
              _buildSectionHeader(context, "আমার ফ্ল্যাশকার্ড")
                  .animate()
                  .moveX(begin: -20, end: 0, duration: 400.ms),
              const Gap(8),
              _buildFlashcardSection(maxWidth)
                  .animate()
                  .fadeIn()
                  .shimmer(duration: 1000.ms),
              const Gap(16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: LeaderboardSection(),
              ).animate().scale(duration: 500.ms),
              const Gap(16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileShimmer(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const Gap(16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 80,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: 1200.ms,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.7)
              : Colors.white.withOpacity(0.9),
          size: 0.8,
          delay: 300.ms,
        );
  }

  Widget _buildTopSection(double maxWidth) {
    final userProfileAsyncValue = ref.watch(cachedUserProfileProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkTheme = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkTheme
              ? [
                  AppColors.homeScreenTopDark,
                  AppColors.scaffoldBackgroundDark,
                ]
              : [
                  AppColors.homeScreenTopLight,
                  AppColors.homeScreenBottomLight,
                ],
          stops: const [0.0, 0.5],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  UserProfileView(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            final offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: userProfileAsyncValue.when(
                      data: (userData) {
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: userData.data!.image == null
                                  ? const AssetImage(
                                          'assets/images/test_dp.jpg')
                                      as ImageProvider
                                  : CachedNetworkImageProvider(
                                      userData.data!.image!.path!),
                            ),
                            const Gap(16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${userData.data!.name}',
                                  style:
                                      Theme.of(context).textTheme.titleSmall!,
                                ),
                                Text(
                                  context.l10n!.seeProfile,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium!,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      error: (error, stackTrace) {
                        _log.e(error.toString());
                        return const Text("Error loading profile");
                      },
                      loading: () {
                        return _buildProfileShimmer(context);
                      },
                    ),
                  ),
                  const Gap(16),

                  /*Padding(
                    padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.05),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.w600),
                        children: const <TextSpan>[
                          TextSpan(
                            text: 'এআই সমাধান ',
                            style: TextStyle(
                                color: AppColors.textActionSecondaryLight),
                          ),
                          TextSpan(
                            text: 'দিয়ে আপনার সমস্যার সমাধান করুন',
                          ),
                        ],
                      ),
                    ),
                  ),*/

                  const Gap(16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const SearchView(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeOut;

                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            final offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.textTertiaryLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'সার্চ করুন.....',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: AppColors.textTertiaryLight,
                                    fontWeight: FontWeight.w500),
                          ),
                          SvgPicture.asset("assets/icons/search_icon.svg"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Nav().push(CourseListView());
                    },
                    child: CategoryCard(
                      icon: "assets/icons/courses_icon.png",
                      text: context.l10n!.courses,
                      image: 'assets/images/courses_background.png',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => Nav().push(MyCourseView()),
                    child: CategoryCard(
                      icon: "assets/icons/my_courses_icon.png",
                      text: context.l10n!.myCourses,
                      image: 'assets/images/my_courses_background.png',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdSection(double maxWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                'assets/images/ad_banner.png',
                height: 120,
                width: maxWidth,
                fit: BoxFit.cover,
              ),
            ),
            const Gap(8),
            SmoothPageIndicator(
              controller: _adController,
              count: 1,
              effect: const ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.blue,
                dotColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardSection(double maxWidth) {
    final flashcardsAsync = ref.watch(userFlashcardsProvider);

    return SizedBox(
      height: 220,
      child: flashcardsAsync.when(
        data: (flashcards) {
          if (flashcards.isEmpty) {
            return Center(
              child: Text(
                context.l10n!.emptyFlashcardMessage,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return _buildHorizontalFlashcardList(flashcards, maxWidth);
        },
        loading: () => HorizontalFlashcardListLoading(maxWidth: maxWidth),
        error: (error, stack) => Center(
          child: Text('${context.l10n!.error}: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildHorizontalFlashcardList(
      List<Flashcard> flashcards, double maxWidth) {
    final flashcardNotifier = ref.read(userFlashcardsProvider.notifier);

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.pixels >=
            scrollNotification.metrics.maxScrollExtent * 0.8) {
          flashcardNotifier.loadMoreData();
        }
        return false;
      },
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          if (index == flashcards.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 80),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final flashcard = flashcards[index];
          final cardColor = _getFlashcardColor(index, context);

          return InkWell(
            onTap: () {
              Nav().push(FlashcardStudyView(
                  flashcardId: flashcards[index].sId!,
                  flashcardTitle: flashcards[index].title!));
            },
            child: Container(
              width: maxWidth * 0.8,
              padding: EdgeInsets.only(
                left: index == 0 ? 16 : 8,
                right: index == flashcards.length - 1 ? 16 : 8,
                top: 12,
                bottom: 12,
              ),
              child: Card(
                elevation: 12,
                shadowColor: cardColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _buildModernBackground(cardColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (flashcard.studentId != null)
                              Align(
                                alignment: Alignment.topRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor:
                                          cardColor.withOpacity(0.2),
                                      child: Icon(
                                        Icons.person,
                                        size: 16,
                                        color: cardColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'By ${flashcard.studentId!.name}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  flashcard.title!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cardColor.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernBackground(Color baseColor) {
    return CustomPaint(
      painter: ModernFlashcardBackgroundPainter(
        baseColor: baseColor,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(fontWeight: FontWeight.w600),
          ),
          TextButton(
            onPressed: () {
              if (title == "আমার ফ্ল্যাশকার্ড") {
                _handleTabChange(1);
              }
            },
            child: Text(
              "আরো দেখুন",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiaryLight),
            ),
          ),
        ],
      ),
    );
  }
}

Color _getFlashcardColor(int index, BuildContext context) {
  final colors = [
    Theme.of(context).colorScheme.secondary,
    Theme.of(context).unselectedWidgetColor,
    Theme.of(context).colorScheme.error,
    Colors.orange,
    Colors.green,
  ];
  return colors[index % colors.length];
}
