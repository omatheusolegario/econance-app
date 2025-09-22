import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // dark background
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
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: "Welcome to "),
                      TextSpan(
                        text: "€conance",
                        style: TextStyle(color: Color(0xFF4ADE80)), // green accent
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  "The ultimate and most comprehensive financial management app.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
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
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Create account
                TextButton(
                  onPressed: () {

                    // TODO: Navigate to register
                  },
                  child: const Text(
                    "Create an account",
                    style: TextStyle(color: Colors.white70),
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
