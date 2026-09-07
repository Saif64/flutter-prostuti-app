import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prostuti/features/auth/onboarding/view/onboarding_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widgets/main_app_content.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create a curved animation for more natural feel
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Create the scale animation from 0.5 to 1.0
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_animation);

    // Start the animation
    _controller.forward();

    // Check if user is new and navigate accordingly after animation completes
    Timer(const Duration(seconds: 1), () {
      _checkFirstTimeUser().then((isFirstTime) {
        if (isFirstTime) {
          // Navigate to onboarding for first-time users
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const OnboardingView()));
        } else {
          // Navigate directly to main app for returning users
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const MainAppContent()));
        }
      });
    });
  }

  // Function to check if user is opening the app for the first time
  Future<bool> _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the boolean value, defaulting to true if it doesn't exist
    final isFirstTime = prefs.getBool('isFirstTimeUser') ?? true;

    // If this is the first time, update the shared preference for next time
    if (isFirstTime) {
      await prefs.setBool('isFirstTimeUser', false);
    }

    return isFirstTime;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build method remains unchanged
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo
              ScaleTransition(
                scale: _animation,
                child: Image.asset(
                  'assets/images/prostuti_splash_screen.png',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
