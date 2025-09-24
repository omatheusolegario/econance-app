import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:carousel_slider/carousel_slider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _CarrouselPageState();
}

class _CarrouselPageState extends State<WelcomePage> {
  final List<String> images = [
    'assets/images/onboarding1.png',
    'assets/images/onboarding2.png',
    'assets/images/onboarding3.png',
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> subtitles = [
      AppLocalizations.of(context)!.carousel1,
      AppLocalizations.of(context)!.carousel2,
      AppLocalizations.of(context)!.carousel3,
    ];
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // dark background
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Carousel
                CarouselSlider(
                  options: CarouselOptions(
                    height: 220,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 6),
                    onPageChanged: (index, reason) {
                      setState(() => currentIndex = index);
                    },
                  ),
                  items: images.map((path) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        path,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 40),

                // Title
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge,
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.welcomeMessage,
                      ),
                      WidgetSpan(child: SizedBox(width: 5)),
                      TextSpan(
                        text: "€",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor, // green accent
                          fontFamily: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.fontFamily,
                          fontSize: 20,
                        ),
                      ),
                      const TextSpan(text: "conance"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                  subtitles[currentIndex],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 30),

                // Page indicator (3 dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(isActive: currentIndex == 0),
                    const SizedBox(width: 6),
                    _buildDot(isActive: currentIndex == 1),
                    const SizedBox(width: 6),
                    _buildDot(isActive: currentIndex == 2),
                  ],
                ),

                const SizedBox(height: 40),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      AppLocalizations.of(context)!.login,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Create account
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/register");
                  },
                  child: Text(
                    AppLocalizations.of(context)!.createAccount,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF87D4B1) : const Color(0xFFD9D9D9),
        shape: BoxShape.circle,
      ),
    );
  }
}
