import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Readify/screen/onboarding_screen.dart';
import 'package:Readify/screen/homeScreen.dart';
import 'package:Readify/screen/signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));
  }

  void _startSplashSequence() async {
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      final user = FirebaseAuth.instance.currentUser;

      if (!hasSeenOnboarding) {
        Get.offAll(() => const OnboardingScreen());
      } else if (user != null) {
        Get.offAll(() => HomePage(
              userName: user.displayName ?? 'User',
              userEmail: user.email ?? '',
              userPhoto: user.photoURL,
            ));
      } else {
        Get.offAll(() => const SignupScreen());
      }
    } catch (e) {
      Get.offAll(() => const OnboardingScreen());
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              colorScheme.primary.withOpacity(0.9),
              colorScheme.secondary.withOpacity(0.7),
              colorScheme.tertiary.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              Expanded(
                flex: 3,
                child: Center(
                  child: ScaleTransition(
                    scale: _logoAnimation,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 65,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Texts
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Name with shimmer effect
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _textFadeAnimation,
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.blueAccent.shade100,
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            "Readify",
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Tagline
                    FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Text(
                        "Your Digital Library Awaits",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Modern loading dots
                    FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return AnimatedBuilder(
                            animation: _textController,
                            builder: (context, child) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Transform.scale(
                                  scale: 1 +
                                      (0.3 *
                                          (1 -
                                              ((index * 0.3 -
                                                      _textController.value)
                                                  .abs()
                                                  .clamp(0.0, 1.0)))),
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Text(
                    "Powered by Flutter",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.75),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
