import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:prostuti/common/helpers/theme_provider.dart';
import 'package:prostuti/common/widgets/long_button.dart';
import 'package:prostuti/core/services/debouncer.dart';
import 'package:prostuti/core/services/error_handler.dart';
import 'package:prostuti/core/services/localization_service.dart';
import 'package:prostuti/features/auth/forget_password/repository/forget_password_repo.dart';
import 'package:prostuti/features/auth/login/view/login_view.dart';
import 'package:prostuti/features/auth/signup/viewmodel/otp_viewmodel.dart';
import 'package:prostuti/features/auth/signup/viewmodel/phone_number_viewmodel.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NewPasswordView extends ConsumerStatefulWidget {
  const NewPasswordView({super.key});

  @override
  NewPasswordViewState createState() => NewPasswordViewState();
}

class NewPasswordViewState extends ConsumerState<NewPasswordView> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 120);
  final _loadingProvider = StateProvider<bool>((ref) => false);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n!.passwordRequired;
    }
    if (value.length < 6) {
      return context.l10n!.passwordMinLengthMessage;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_loadingProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                isDarkMode
                    ? "assets/images/prostuti_logo_dark.svg"
                    : "assets/images/prostuti_logo_light.svg",
                width: 154,
                height: 101,
              ),
              const Gap(118),
              Text(
                context.l10n!.forgotPassword,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Gap(32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n!.password,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Gap(6),
                    TextFormField(
                      validator: _validatePassword,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      controller: _passwordController,
                      decoration: InputDecoration(
                          hintText: context.l10n!.enterYourPassword),
                    ),
                    Text(
                      context.l10n!.confirmPassword,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Gap(6),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                          hintText: context.l10n!.confirmYourPassword),
                    ),
                  ],
                ),
              ),
              const Gap(32),
              Skeletonizer(
                enabled: isLoading,
                child: LongButton(
                  text: context.l10n!.continueText,
                  onPressed: () {
                    _debouncer.run(
                        action: () async {
                          if (_passwordController.text !=
                              _confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text(context.l10n!.passwordsDoNotMatch)),
                            );
                            return;
                          }

                          final payload = {
                            "otpCode": ref.read(otpProvider),
                            "phone": ref.read(phoneNumberProvider),
                            "newPassword": _passwordController.text,
                            "confirmNewPassword":
                                _confirmPasswordController.text,
                          };
                          if (_formKey.currentState!.validate()) {
                            try {
                              final response = await ref
                                  .read(forgetPasswordRepoProvider)
                                  .resetPassword(payload: payload);

                              if (response && context.mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => const LoginView()),
                                );
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content:
                                      Text(ErrorHandler().getErrorMessage()),
                                ));
                                _debouncer.cancel();
                                ErrorHandler().clearErrorMessage();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text(context.l10n!.anErrorOccurred)),
                                );
                              }
                            }
                          }
                        },
                        loadingController: ref.read(_loadingProvider.notifier));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
