import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:prostuti/common/helpers/theme_provider.dart';
import 'package:prostuti/common/widgets/long_button.dart';
import 'package:prostuti/core/configs/app_colors.dart';
import 'package:prostuti/core/services/debouncer.dart';
import 'package:prostuti/core/services/error_handler.dart';
import 'package:prostuti/core/services/localization_service.dart';
import 'package:prostuti/core/services/nav.dart';
import 'package:prostuti/features/auth/forget_password/view/forget_password_view.dart';
import 'package:prostuti/features/auth/login/repository/login_repo.dart';
import 'package:prostuti/features/auth/login/viewmodel/login_viewmodel.dart';
import 'package:prostuti/features/auth/signup/widgets/label.dart';
import 'package:prostuti/features/home_screen/view/home_screen_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../signup/view/phone_view.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends ConsumerState<LoginView> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 120);
  final _loadingProvider = StateProvider<bool>((ref) => false);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
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
    bool rememberMe = ref.watch(rememberMeProvider);
    final isLoading = ref.watch(_loadingProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(80),
              SvgPicture.asset(
                isDarkMode
                    ? "assets/images/prostuti_logo_dark.svg"
                    : "assets/images/prostuti_logo_light.svg",
                width: 154,
                height: 101,
              ),
              const Gap(60),
              Text(
                context.l10n!.loginToYourAccount,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Gap(8),
              Text(
                context.l10n!.welcomeBack,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Gap(32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Label(
                      text: context.l10n!.phoneNumber,
                    ),
                    const Gap(6),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.l10n!.phoneRequired;
                        }
                        if (value.length != 11) {
                          return context.l10n!.phoneMustBe11Digits;
                        }
                        return null; // Returns null if validation is successful
                      },
                      keyboardType: TextInputType.number,
                      controller: _phoneController,
                      decoration: InputDecoration(
                          hintText: context.l10n!.enterYourPhoneNumber),
                    ),
                    const Gap(20),
                    Label(
                      text: context.l10n!.password,
                    ),
                    const Gap(6),
                    TextFormField(
                      validator: _validatePassword,
                      keyboardType: TextInputType.text,
                      obscureText: ref.watch(rememberMeProvider) ? false : true,
                      controller: _passwordController,
                      decoration: InputDecoration(
                          hintText: context.l10n!.enterYourPassword),
                    ),
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: Checkbox(
                                value: rememberMe,
                                checkColor: Colors.white,
                                onChanged: (value) {
                                  ref
                                      .read(rememberMeProvider.notifier)
                                      .toggleCheckBox(value);
                                },
                              ),
                            ),
                            const Gap(8),
                            Text(
                              context.l10n!.showPassword,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ForgetPasswordView(),
                            ));
                          },
                          child: Text(
                            context.l10n!.forgotPassword,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: AppColors.textActionTertiaryLight,
                                      fontWeight: FontWeight.w900,
                                    ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(24),
              Skeletonizer(
                enabled: isLoading,
                child: LongButton(
                    text: context.l10n!.login,
                    onPressed: () {
                      if (_phoneController.text.isEmpty &&
                          _passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "${context.l10n!.phoneNumber} ${context.l10n!.and} ${context.l10n!.password} ${context.l10n!.mustNotBeEmpty}"),
                        ));
                        return;
                      }

                      if (_formKey.currentState!.validate()) {
                        _debouncer.run(
                            action: () async {
                              final payload = {
                                "phone": "+88${_phoneController.text}",
                                "password": _passwordController.text,
                              };

                              final response = await ref
                                  .read(loginRepoProvider)
                                  .loginUser(
                                      payload: payload,
                                      rememberMe: rememberMe,
                                      ref: ref);

                              if (response.data != null) {
                                Nav().pushAndRemoveUntil(HomeScreen());
                              } else if (response.error != null) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content:
                                        Text(ErrorHandler().getErrorMessage()),
                                  ));
                                }
                                _debouncer.cancel();
                                ErrorHandler().clearErrorMessage();
                              }
                            },
                            loadingController:
                                ref.read(_loadingProvider.notifier));
                      }
                    }),
              ),
              const Gap(24),
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PhoneView(),
                )),
                child: RichText(
                  text: TextSpan(
                    text: '${context.l10n!.noAccount} ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: <TextSpan>[
                      TextSpan(
                          text: context.l10n!.signUp,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.textActionSecondaryLight,
                                    fontWeight: FontWeight.w900,
                                  )),
                    ],
                  ),
                ),
              ),
              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }
}
