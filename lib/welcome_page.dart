import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                // Illustration
                Image.asset(
                  "./assets/images/onboarding.png", // put your illustration here
                  height: 220,
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
                      TextSpan(
                        text: " €conance",
                        style: TextStyle(
                          color: Color(0xFF4ADE80),
                        ), // green accent
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  AppLocalizations.of(context)!.carousel1,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 30),

                // Page indicator (3 dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(isActive: false),
                    const SizedBox(width: 6),
                    _buildDot(isActive: true),
                    const SizedBox(width: 6),
                    _buildDot(isActive: false),
                  ],
                ),
                const SizedBox(height: 40),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ADE80),
                      foregroundColor: Colors.black,
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
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Create account
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to register
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
        color: isActive ? Colors.white : Colors.grey[600],
        shape: BoxShape.circle,
      ),
    );
  }
}
