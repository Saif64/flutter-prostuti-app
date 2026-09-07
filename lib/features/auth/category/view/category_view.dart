import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:prostuti/common/widgets/common_widgets/common_widgets.dart';
import 'package:prostuti/common/widgets/long_button.dart';
import 'package:prostuti/core/configs/app_colors.dart';
import 'package:prostuti/core/services/debouncer.dart';
import 'package:prostuti/core/services/error_handler.dart';
import 'package:prostuti/core/services/localization_service.dart';
import 'package:prostuti/core/services/nav.dart';
import 'package:prostuti/features/auth/category/model/category_constant.dart';
import 'package:prostuti/features/auth/category/repository/category_repo.dart';
import 'package:prostuti/features/auth/login/view/login_view.dart';
import 'package:prostuti/features/auth/signup/repository/signup_repo.dart';
import 'package:prostuti/features/auth/signup/viewmodel/email_viewmodel.dart';
import 'package:prostuti/features/auth/signup/viewmodel/name_viewmodel.dart';
import 'package:prostuti/features/auth/signup/viewmodel/otp_viewmodel.dart';
import 'package:prostuti/features/auth/signup/viewmodel/password_viewmodel.dart';
import 'package:prostuti/features/auth/signup/viewmodel/phone_number_viewmodel.dart';
import 'package:prostuti/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:prostuti/generated/assets.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Category picker, used both as the last step of registration and from the
/// profile screen to change an existing category.
///
/// The backend only understands `categoryType` (Academic | Admission | Job) --
/// there is no sub-category -- so this is a single-choice screen. Selecting is
/// separate from submitting: tapping only marks a choice, the confirm button
/// commits it.
class CategoryView extends ConsumerStatefulWidget {
  final bool isRegistration;
  final String? studentId;

  const CategoryView({super.key, this.isRegistration = true, this.studentId});

  @override
  CategoryViewState createState() => CategoryViewState();
}

class CategoryViewState extends ConsumerState<CategoryView> with CommonWidgets {
  final _loadingProvider = StateProvider<bool>((ref) => false);
  final _debouncer = Debouncer(milliseconds: 120);

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();

    // When changing the category from the profile, start from the current one.
    if (!widget.isRegistration) {
      _loadCurrentCategory();
    }
  }

  void _loadCurrentCategory() {
    Future.microtask(() async {
      ref.read(_loadingProvider.notifier).state = true;

      try {
        final userProfile = await ref.read(userProfileProvider.future);
        final current = userProfile.data?.categoryType;
        if (current != null && mounted) {
          setState(() => _selectedCategory = current);
        }
      } catch (e) {
        if (mounted) {
          _showMessage("${context.l10n!.anErrorOccurred}: $e");
        }
      } finally {
        if (mounted) {
          ref.read(_loadingProvider.notifier).state = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_loadingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: commonAppbar(widget.isRegistration
          ? context.l10n!.category
          : context.l10n!.updateCategory),
      body: Skeletonizer(
        enabled: isLoading,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n!.selectCategory,
                style: theme.textTheme.titleMedium,
              ),
              const Gap(16),
              if (!widget.isRegistration && _selectedCategory != null)
                _buildCurrentSelection(context),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16)),
                  child: ListView.builder(
                    itemCount: MainCategory.values.length,
                    itemBuilder: (context, index) {
                      final category = MainCategory.values[index];
                      return _buildCategoryItem(
                        context,
                        category,
                        isSelected: _selectedCategory == category,
                        onSelect: () =>
                            setState(() => _selectedCategory = category),
                      );
                    },
                  ),
                ),
              ),
              const Gap(16),
              LongButton(
                text: context.l10n!.confirm,
                onPressed: _selectedCategory == null ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSelection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _accent(context)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: _accent(context)),
          const Gap(8),
          Expanded(
            child: Text(
              "${context.l10n!.currentCategory}: "
              "${_categoryLabel(context, _selectedCategory!)}",
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String category, {
    required VoidCallback onSelect,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = _accent(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? accent.withOpacity(0.1)
            : theme.scaffoldBackgroundColor,
        border: Border.all(
            color: isSelected
                ? accent
                : (isDark
                    ? AppColors.borderNormalDark
                    : AppColors.borderNormalLight),
            width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Image.asset(
          _categoryIcon(category),
          height: 40,
          width: 40,
        ),
        title: Text(_categoryLabel(context, category)),
        onTap: onSelect,
        trailing: Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? accent : theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  void _submit() {
    if (_selectedCategory == null) {
      _showMessage(context.l10n!.pleaseSelectYourCategory);
      return;
    }

    if (widget.isRegistration) {
      _registerWithCategory();
    } else {
      _updateCategory();
    }
  }

  void _registerWithCategory() {
    _debouncer.run(
        action: () async {
          final payload = {
            "otpCode": ref.read(otpProvider),
            "name": ref.read(nameViewmodelProvider),
            "email": ref.read(emailViewmodelProvider),
            "phone": "+88${ref.read(phoneNumberProvider)}",
            "password": ref.read(passwordViewmodelProvider),
            "confirmPassword": ref.read(passwordViewmodelProvider),
            "categoryType": _selectedCategory,
          };

          final response =
              await ref.read(signupRepoProvider).registerStudent(payload);

          if (!mounted) return;

          if (response.data != null) {
            Fluttertoast.showToast(msg: context.l10n!.signupSuccessful);
            Nav().pushAndRemoveUntil(const LoginView());
          } else {
            _showMessage(ErrorHandler().getErrorMessage());
            _debouncer.cancel();
            ErrorHandler().clearErrorMessage();
          }
        },
        loadingController: ref.read(_loadingProvider.notifier));
  }

  void _updateCategory() {
    _debouncer.run(
      action: () async {
        final response = await ref
            .read(categoryRepoProvider)
            .updateStudentCategory(_selectedCategory!);

        if (!mounted) return;

        if (response.data != null) {
          ref.invalidate(userProfileProvider);
          Fluttertoast.showToast(msg: context.l10n!.categoryUpdatedSuccessfully);
          Navigator.pop(context);
        } else {
          _showMessage(ErrorHandler().getErrorMessage());
          _debouncer.cancel();
          ErrorHandler().clearErrorMessage();
        }
      },
      loadingController: ref.read(_loadingProvider.notifier),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// The accent the rest of the app uses for a selected/primary state.
  /// `Theme.of(context).primaryColor` is white in the light theme, so it cannot
  /// be used for borders or check marks here.
  Color _accent(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundActionPrimaryDark
          : AppColors.backgroundActionPrimaryLight;

  /// The wire value stays English; only the label is localized.
  String _categoryLabel(BuildContext context, String category) {
    switch (category) {
      case MainCategory.ACADEMIC:
        return context.l10n!.academic;
      case MainCategory.ADMISSION:
        return context.l10n!.admission;
      case MainCategory.JOB:
        return context.l10n!.job;
      default:
        return category;
    }
  }

  String _categoryIcon(String category) {
    switch (category) {
      case MainCategory.ADMISSION:
        return Assets.imagesMortarboard01;
      case MainCategory.JOB:
        return Assets.imagesBriefcase01;
      case MainCategory.ACADEMIC:
      default:
        return Assets.imagesBackpack03;
    }
  }
}
