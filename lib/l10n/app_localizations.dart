import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @flashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcards;

  /// No description provided for @createFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Create Flashcard'**
  String get createFlashcard;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Subject, Chapter and Unit'**
  String get titleHint;

  /// No description provided for @term.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get term;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Another Card'**
  String get addCard;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @exploration.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploration;

  /// No description provided for @yourFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Your Flashcards'**
  String get yourFlashcards;

  /// No description provided for @createNewFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Create New Flashcard'**
  String get createNewFlashcard;

  /// No description provided for @recentFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Recent Flashcards'**
  String get recentFlashcards;

  /// No description provided for @yourFlashcardsList.
  ///
  /// In en, this message translates to:
  /// **'Your Flashcards List'**
  String get yourFlashcardsList;

  /// No description provided for @emptyFlashcardMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no flashcards here'**
  String get emptyFlashcardMessage;

  /// No description provided for @emptyYourFlashcardMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any flashcards'**
  String get emptyYourFlashcardMessage;

  /// No description provided for @endOfList.
  ///
  /// In en, this message translates to:
  /// **'You\'ve seen all flashcards'**
  String get endOfList;

  /// No description provided for @setOptions.
  ///
  /// In en, this message translates to:
  /// **'Set Options'**
  String get setOptions;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @visibleBy.
  ///
  /// In en, this message translates to:
  /// **'Visible By'**
  String get visibleBy;

  /// No description provided for @onlyMe.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get onlyMe;

  /// No description provided for @everyone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get everyone;

  /// No description provided for @cardCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Flashcard successfully created!'**
  String get cardCreatedSuccessfully;

  /// No description provided for @swipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get swipe;

  /// No description provided for @viewCardList.
  ///
  /// In en, this message translates to:
  /// **'View Card List'**
  String get viewCardList;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @youHaveAchieved.
  ///
  /// In en, this message translates to:
  /// **'You have achieved'**
  String get youHaveAchieved;

  /// No description provided for @learned.
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get learned;

  /// No description provided for @learning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// No description provided for @reviewCardsAgain.
  ///
  /// In en, this message translates to:
  /// **'Review Cards Again'**
  String get reviewCardsAgain;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Search flashcards...'**
  String get searchFlashcards;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @openFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Open flashcard'**
  String get openFlashcard;

  /// No description provided for @openYourFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Open your flashcard'**
  String get openYourFlashcard;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @loadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get loadingMore;

  /// No description provided for @noFlashcardItems.
  ///
  /// In en, this message translates to:
  /// **'No flashcard items found for this set'**
  String get noFlashcardItems;

  /// No description provided for @swipeLeftToLearn.
  ///
  /// In en, this message translates to:
  /// **'Swipe Left to Learn'**
  String get swipeLeftToLearn;

  /// No description provided for @swipeRightToKnow.
  ///
  /// In en, this message translates to:
  /// **'Swipe Right to Know'**
  String get swipeRightToKnow;

  /// No description provided for @favoriteAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get favoriteAdded;

  /// No description provided for @favoriteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get favoriteRemoved;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @loginToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginToYourAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Enter your details.'**
  String get welcomeBack;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneMustBe11Digits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 11 digits'**
  String get phoneMustBe11Digits;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter, one special character, and be at least 8 characters long'**
  String get passwordValidationMessage;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @signupSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get signupSuccessful;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @enterOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code sent to your number'**
  String get enterOtpCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @registerYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Register your account'**
  String get registerYourAccount;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmailRequired;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @mockTest.
  ///
  /// In en, this message translates to:
  /// **'Mock Test'**
  String get mockTest;

  /// No description provided for @clearYourDoubts.
  ///
  /// In en, this message translates to:
  /// **'Clear Your Doubts'**
  String get clearYourDoubts;

  /// No description provided for @onboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.'**
  String get onboardingDesc;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'And'**
  String get and;

  /// No description provided for @mustNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'must not be empty'**
  String get mustNotBeEmpty;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @youAreOnPremiumPlan.
  ///
  /// In en, this message translates to:
  /// **'You are on a premium plan'**
  String get youAreOnPremiumPlan;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to premium'**
  String get upgradeToPremium;

  /// No description provided for @yourPoints.
  ///
  /// In en, this message translates to:
  /// **'Your Points'**
  String get yourPoints;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @profileInformation.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInformation;

  /// No description provided for @myItems.
  ///
  /// In en, this message translates to:
  /// **'My Items'**
  String get myItems;

  /// No description provided for @myCourses.
  ///
  /// In en, this message translates to:
  /// **'My Courses'**
  String get myCourses;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @testHistory.
  ///
  /// In en, this message translates to:
  /// **'Test History'**
  String get testHistory;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @flashCard.
  ///
  /// In en, this message translates to:
  /// **'Flash Card'**
  String get flashCard;

  /// No description provided for @test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @courses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get courses;

  /// No description provided for @testCategory.
  ///
  /// In en, this message translates to:
  /// **'Test Category'**
  String get testCategory;

  /// No description provided for @topCourseList.
  ///
  /// In en, this message translates to:
  /// **'Top Course List'**
  String get topCourseList;

  /// No description provided for @searchCourses.
  ///
  /// In en, this message translates to:
  /// **'Search courses...'**
  String get searchCourses;

  /// No description provided for @noCourses.
  ///
  /// In en, this message translates to:
  /// **'No courses found'**
  String get noCourses;

  /// No description provided for @courseDetails.
  ///
  /// In en, this message translates to:
  /// **'Course Details'**
  String get courseDetails;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @enroll.
  ///
  /// In en, this message translates to:
  /// **'Enroll'**
  String get enroll;

  /// No description provided for @courseContent.
  ///
  /// In en, this message translates to:
  /// **'Course Content'**
  String get courseContent;

  /// No description provided for @coursePreview.
  ///
  /// In en, this message translates to:
  /// **'Course Preview'**
  String get coursePreview;

  /// No description provided for @aboutTest.
  ///
  /// In en, this message translates to:
  /// **'About Course'**
  String get aboutTest;

  /// No description provided for @courseCurriculum.
  ///
  /// In en, this message translates to:
  /// **'Course Curriculum'**
  String get courseCurriculum;

  /// No description provided for @testReviews.
  ///
  /// In en, this message translates to:
  /// **'Course Reviews'**
  String get testReviews;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @visit.
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get visit;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'students'**
  String get students;

  /// No description provided for @tests.
  ///
  /// In en, this message translates to:
  /// **'tests'**
  String get tests;

  /// No description provided for @recordedClasses.
  ///
  /// In en, this message translates to:
  /// **'recorded classes'**
  String get recordedClasses;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'lessons'**
  String get lessons;

  /// No description provided for @recordedClass.
  ///
  /// In en, this message translates to:
  /// **'Recorded Class'**
  String get recordedClass;

  /// No description provided for @resource.
  ///
  /// In en, this message translates to:
  /// **'Resource'**
  String get resource;

  /// No description provided for @assignment.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get assignment;

  /// No description provided for @enrolledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Enrolled into the free course. Enjoy'**
  String get enrolledSuccess;

  /// No description provided for @alreadyEnrolled.
  ///
  /// In en, this message translates to:
  /// **'Already Enrolled in the course'**
  String get alreadyEnrolled;

  /// No description provided for @contactProstuti.
  ///
  /// In en, this message translates to:
  /// **'Contact Prostuti for enrollment'**
  String get contactProstuti;

  /// No description provided for @enrollInCourse.
  ///
  /// In en, this message translates to:
  /// **'Enroll'**
  String get enrollInCourse;

  /// No description provided for @visitCourse.
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get visitCourse;

  /// No description provided for @seeDetails.
  ///
  /// In en, this message translates to:
  /// **'See Details'**
  String get seeDetails;

  /// No description provided for @noCourseAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Course Available'**
  String get noCourseAvailable;

  /// No description provided for @exploreCourses.
  ///
  /// In en, this message translates to:
  /// **'Explore Courses'**
  String get exploreCourses;

  /// No description provided for @courseProgress.
  ///
  /// In en, this message translates to:
  /// **'Course Progress'**
  String get courseProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @startLearning.
  ///
  /// In en, this message translates to:
  /// **'Start Learning'**
  String get startLearning;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeMessage;

  /// No description provided for @modules.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get modules;

  /// No description provided for @routine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routine;

  /// No description provided for @reportCard.
  ///
  /// In en, this message translates to:
  /// **'Report Card'**
  String get reportCard;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @notice.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get notice;

  /// No description provided for @recordedClassItem.
  ///
  /// In en, this message translates to:
  /// **'Recorded Class: '**
  String get recordedClassItem;

  /// No description provided for @resourceItem.
  ///
  /// In en, this message translates to:
  /// **'Resource: '**
  String get resourceItem;

  /// No description provided for @assignmentItem.
  ///
  /// In en, this message translates to:
  /// **'Assignment: '**
  String get assignmentItem;

  /// No description provided for @testItem.
  ///
  /// In en, this message translates to:
  /// **'Test: '**
  String get testItem;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @notices.
  ///
  /// In en, this message translates to:
  /// **'Notices'**
  String get notices;

  /// No description provided for @todaysNotices.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Notices'**
  String get todaysNotices;

  /// No description provided for @yesterdaysNotices.
  ///
  /// In en, this message translates to:
  /// **'Yesterday\'s Notices'**
  String get yesterdaysNotices;

  /// No description provided for @olderNotices.
  ///
  /// In en, this message translates to:
  /// **'Older Notices'**
  String get olderNotices;

  /// No description provided for @noNotices.
  ///
  /// In en, this message translates to:
  /// **'No notices available'**
  String get noNotices;

  /// No description provided for @examReminder.
  ///
  /// In en, this message translates to:
  /// **'Exam Reminder'**
  String get examReminder;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @division.
  ///
  /// In en, this message translates to:
  /// **'Division'**
  String get division;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @selectTypeFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a type first'**
  String get selectTypeFirst;

  /// No description provided for @noDivisionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No divisions available for this type'**
  String get noDivisionsAvailable;

  /// No description provided for @noSubjectsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No subjects available for this selection'**
  String get noSubjectsAvailable;

  /// No description provided for @noTypesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No types available'**
  String get noTypesAvailable;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// No description provided for @resetFilter.
  ///
  /// In en, this message translates to:
  /// **'Reset Filter'**
  String get resetFilter;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @availableCategories.
  ///
  /// In en, this message translates to:
  /// **'Available Categories'**
  String get availableCategories;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailable;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get selectType;

  /// No description provided for @selectDivision.
  ///
  /// In en, this message translates to:
  /// **'Select a division'**
  String get selectDivision;

  /// No description provided for @selectSubject.
  ///
  /// In en, this message translates to:
  /// **'Select a subject'**
  String get selectSubject;

  /// No description provided for @noSelectedCategory.
  ///
  /// In en, this message translates to:
  /// **'No category selected'**
  String get noSelectedCategory;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @visibilityOptions.
  ///
  /// In en, this message translates to:
  /// **'Visibility Options'**
  String get visibilityOptions;

  /// No description provided for @visibilityDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose who can see your flashcards'**
  String get visibilityDescription;

  /// No description provided for @everyoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Your flashcard will be visible to all users'**
  String get everyoneDescription;

  /// No description provided for @onlyMeDescription.
  ///
  /// In en, this message translates to:
  /// **'Your flashcard will be visible only to you'**
  String get onlyMeDescription;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @upcomingActivity.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Activity'**
  String get upcomingActivity;

  /// No description provided for @noActivitiesForDay.
  ///
  /// In en, this message translates to:
  /// **'No activities for this day'**
  String get noActivitiesForDay;

  /// No description provided for @noUpcomingActivities.
  ///
  /// In en, this message translates to:
  /// **'No upcoming activities'**
  String get noUpcomingActivities;

  /// No description provided for @classs.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get classs;

  /// No description provided for @exam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get exam;

  /// No description provided for @dueTill.
  ///
  /// In en, this message translates to:
  /// **'Due till'**
  String get dueTill;

  /// No description provided for @at.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get at;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get startChat;

  /// No description provided for @noConversationsFound.
  ///
  /// In en, this message translates to:
  /// **'No conversations found'**
  String get noConversationsFound;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get startConversation;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @attachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attach photo'**
  String get attachPhoto;

  /// No description provided for @attachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get attachFile;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @sendFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a message to start the conversation'**
  String get sendFirstMessage;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get featureComingSoon;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @sendMessageTo.
  ///
  /// In en, this message translates to:
  /// **'Send a message to'**
  String get sendMessageTo;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @searchForUser.
  ///
  /// In en, this message translates to:
  /// **'Search for a user to start a conversation'**
  String get searchForUser;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @noMessageRequests.
  ///
  /// In en, this message translates to:
  /// **'No message requests'**
  String get noMessageRequests;

  /// No description provided for @messageRequestDesc.
  ///
  /// In en, this message translates to:
  /// **'When someone sends you a message for the first time, it will appear here for your approval.'**
  String get messageRequestDesc;

  /// No description provided for @askAQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a Question'**
  String get askAQuestion;

  /// No description provided for @yourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Your Question'**
  String get yourQuestion;

  /// No description provided for @typeYourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Type your question here...'**
  String get typeYourQuestion;

  /// No description provided for @sendQuestion.
  ///
  /// In en, this message translates to:
  /// **'Send Question'**
  String get sendQuestion;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Your message has been sent! Teachers will respond soon.'**
  String get messageSent;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @pendingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Pending Questions'**
  String get pendingQuestions;

  /// No description provided for @activeConversations.
  ///
  /// In en, this message translates to:
  /// **'Active Conversations'**
  String get activeConversations;

  /// No description provided for @waitingForTeacher.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Teacher'**
  String get waitingForTeacher;

  /// No description provided for @noMessagesYetDesc.
  ///
  /// In en, this message translates to:
  /// **'Your conversation will appear here once a teacher responds to your question.'**
  String get noMessagesYetDesc;

  /// No description provided for @todaysRoutine.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Activities'**
  String get todaysRoutine;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @myCalendar.
  ///
  /// In en, this message translates to:
  /// **'My Calender'**
  String get myCalendar;

  /// No description provided for @routineLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Activities'**
  String get routineLoadError;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get tryAgainLater;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noActivitiesToday.
  ///
  /// In en, this message translates to:
  /// **'No Activities Today'**
  String get noActivitiesToday;

  /// No description provided for @enjoyyourFreeTime.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your free time!'**
  String get enjoyyourFreeTime;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatTitle;

  /// No description provided for @broadcast.
  ///
  /// In en, this message translates to:
  /// **'Ask a Teacher'**
  String get broadcast;

  /// No description provided for @askQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask Your Question'**
  String get askQuestion;

  /// No description provided for @questionHint.
  ///
  /// In en, this message translates to:
  /// **'Type your question here...'**
  String get questionHint;

  /// No description provided for @pendingBroadcasts.
  ///
  /// In en, this message translates to:
  /// **'Pending Questions'**
  String get pendingBroadcasts;

  /// No description provided for @activeBroadcasts.
  ///
  /// In en, this message translates to:
  /// **'Active Conversations'**
  String get activeBroadcasts;

  /// No description provided for @noBroadcasts.
  ///
  /// In en, this message translates to:
  /// **'No active requests'**
  String get noBroadcasts;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @messageRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get messageRead;

  /// No description provided for @newQuestion.
  ///
  /// In en, this message translates to:
  /// **'New Question'**
  String get newQuestion;

  /// No description provided for @questionSent.
  ///
  /// In en, this message translates to:
  /// **'Your question has been sent. A teacher will respond soon.'**
  String get questionSent;

  /// No description provided for @broadcastExpired.
  ///
  /// In en, this message translates to:
  /// **'Your question request has expired. Please try again.'**
  String get broadcastExpired;

  /// No description provided for @onlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineStatus;

  /// No description provided for @offlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineStatus;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @allMessages.
  ///
  /// In en, this message translates to:
  /// **'All Messages'**
  String get allMessages;

  /// No description provided for @chatError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to chat server'**
  String get chatError;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Retrying...'**
  String get connectionError;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get authError;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @createBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Create a new question to get help'**
  String get createBroadcast;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results'**
  String get noSearchResults;

  /// No description provided for @openChat.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get openChat;

  /// No description provided for @course.
  ///
  /// In en, this message translates to:
  /// **'Course*'**
  String get course;

  /// No description provided for @selectCourse.
  ///
  /// In en, this message translates to:
  /// **'Select Course'**
  String get selectCourse;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @problem.
  ///
  /// In en, this message translates to:
  /// **'Problem*'**
  String get problem;

  /// No description provided for @problemHint.
  ///
  /// In en, this message translates to:
  /// **'Problem Number'**
  String get problemHint;

  /// No description provided for @favoriteItems.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favoriteItems;

  /// No description provided for @allActivities.
  ///
  /// In en, this message translates to:
  /// **'All Activities'**
  String get allActivities;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No Reviews Yet'**
  String get noReviewsYet;

  /// No description provided for @beTheFirstToReview.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share your experience!'**
  String get beTheFirstToReview;

  /// No description provided for @shareYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Share your experience'**
  String get shareYourExperience;

  /// No description provided for @reviewTooShort.
  ///
  /// In en, this message translates to:
  /// **'Review is too short (min 5 characters)'**
  String get reviewTooShort;

  /// No description provided for @reviewTooLong.
  ///
  /// In en, this message translates to:
  /// **'Review is too long (max 1000 characters)'**
  String get reviewTooLong;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully'**
  String get reviewSubmitted;

  /// No description provided for @errorSubmittingReview.
  ///
  /// In en, this message translates to:
  /// **'Error submitting review'**
  String get errorSubmittingReview;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @loadingReviews.
  ///
  /// In en, this message translates to:
  /// **'Loading reviews...'**
  String get loadingReviews;

  /// No description provided for @rateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience'**
  String get rateYourExperience;

  /// No description provided for @submittingReview.
  ///
  /// In en, this message translates to:
  /// **'Submitting review...'**
  String get submittingReview;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @voucher.
  ///
  /// In en, this message translates to:
  /// **'Voucher'**
  String get voucher;

  /// No description provided for @enterVoucherCode.
  ///
  /// In en, this message translates to:
  /// **'Enter voucher code'**
  String get enterVoucherCode;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @voucherApplied.
  ///
  /// In en, this message translates to:
  /// **'Voucher applied successfully!'**
  String get voucherApplied;

  /// No description provided for @enterValidVoucher.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid voucher code'**
  String get enterValidVoucher;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @voucherError.
  ///
  /// In en, this message translates to:
  /// **'Voucher Error'**
  String get voucherError;

  /// No description provided for @voucherNotFound.
  ///
  /// In en, this message translates to:
  /// **'Voucher not found'**
  String get voucherNotFound;

  /// No description provided for @voucherExpired.
  ///
  /// In en, this message translates to:
  /// **'This voucher has expired'**
  String get voucherExpired;

  /// No description provided for @voucherNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'This voucher is not applicable for this purchase'**
  String get voucherNotApplicable;

  /// No description provided for @availableVouchers.
  ///
  /// In en, this message translates to:
  /// **'Available Vouchers'**
  String get availableVouchers;

  /// No description provided for @searchVouchers.
  ///
  /// In en, this message translates to:
  /// **'Search vouchers'**
  String get searchVouchers;

  /// No description provided for @noVouchersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No vouchers available'**
  String get noVouchersAvailable;

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on'**
  String get expiresOn;

  /// No description provided for @specialForYou.
  ///
  /// In en, this message translates to:
  /// **'Special for you!'**
  String get specialForYou;

  /// No description provided for @courseSpecific.
  ///
  /// In en, this message translates to:
  /// **'Course specific'**
  String get courseSpecific;

  /// No description provided for @generalVoucher.
  ///
  /// In en, this message translates to:
  /// **'General voucher'**
  String get generalVoucher;

  /// No description provided for @youSave.
  ///
  /// In en, this message translates to:
  /// **'You save'**
  String get youSave;

  /// No description provided for @tapToApply.
  ///
  /// In en, this message translates to:
  /// **'Tap to apply'**
  String get tapToApply;

  /// No description provided for @selectVoucher.
  ///
  /// In en, this message translates to:
  /// **'Select voucher'**
  String get selectVoucher;

  /// No description provided for @discountApplied.
  ///
  /// In en, this message translates to:
  /// **'Discount applied'**
  String get discountApplied;

  /// No description provided for @vouchers.
  ///
  /// In en, this message translates to:
  /// **'Vouchers'**
  String get vouchers;

  /// No description provided for @pleaseSelectYourCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred category'**
  String get pleaseSelectYourCategory;

  /// No description provided for @subcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get subcategory;

  /// No description provided for @pleaseSelectYourSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred subcategory'**
  String get pleaseSelectYourSubcategory;

  /// No description provided for @noSubcategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No subcategories found'**
  String get noSubcategoriesFound;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @categoryUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdatedSuccessfully;

  /// No description provided for @studentIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Student ID not found'**
  String get studentIdNotFound;

  /// No description provided for @academic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get academic;

  /// No description provided for @admission.
  ///
  /// In en, this message translates to:
  /// **'Admission'**
  String get admission;

  /// No description provided for @job.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get job;

  /// No description provided for @science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get science;

  /// No description provided for @commerce.
  ///
  /// In en, this message translates to:
  /// **'Commerce'**
  String get commerce;

  /// No description provided for @arts.
  ///
  /// In en, this message translates to:
  /// **'Arts'**
  String get arts;

  /// No description provided for @engineering.
  ///
  /// In en, this message translates to:
  /// **'Engineering'**
  String get engineering;

  /// No description provided for @medical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get medical;

  /// No description provided for @university.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get university;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @confirmYourNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new password'**
  String get confirmYourNewPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get confirmPasswordRequired;

  /// No description provided for @updateCategory.
  ///
  /// In en, this message translates to:
  /// **'Update Category'**
  String get updateCategory;

  /// No description provided for @currentCategory.
  ///
  /// In en, this message translates to:
  /// **'Current Category'**
  String get currentCategory;

  /// No description provided for @selectNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Select New Category'**
  String get selectNewCategory;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @noChangesDetected.
  ///
  /// In en, this message translates to:
  /// **'No changes detected'**
  String get noChangesDetected;

  /// No description provided for @errorUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get errorUpdatingProfile;

  /// No description provided for @howToCreateFlashcard.
  ///
  /// In en, this message translates to:
  /// **'How to create flashcards?'**
  String get howToCreateFlashcard;

  /// No description provided for @howToPurchaseTestCourse.
  ///
  /// In en, this message translates to:
  /// **'How to purchase test courses?'**
  String get howToPurchaseTestCourse;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @contactUsForAnyQuestions.
  ///
  /// In en, this message translates to:
  /// **'Contact us for any questions'**
  String get contactUsForAnyQuestions;

  /// No description provided for @supportDescription.
  ///
  /// In en, this message translates to:
  /// **'Our support team is available to help you with any questions or issues you might have with the app.'**
  String get supportDescription;

  /// No description provided for @helplineCall.
  ///
  /// In en, this message translates to:
  /// **'Call Helpline'**
  String get helplineCall;

  /// No description provided for @messageToSupport.
  ///
  /// In en, this message translates to:
  /// **'Message Support'**
  String get messageToSupport;

  /// No description provided for @seeProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get seeProfile;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn': return AppLocalizationsBn();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
