import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prostuti/features/auth/login/view/login_view.dart';
import 'package:prostuti/features/home_screen/view/home_screen_view.dart';

import '../view_model/auth_notifier.dart';

/// Routes to the home screen or the login screen depending on whether a token
/// is stored. Shown after the splash screen for returning users.
class MainAppContent extends ConsumerWidget {
  const MainAppContent({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final authNotifier = ref.watch(authNotifierProvider);

    return authNotifier.when(
      data: (token) {
        if (token != null) {
          return const HomeScreen(); // User is logged in
        } else {
          return const LoginView(); // Redirect to login
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const LoginView(), // Redirect to login on error
    );
  }
}
