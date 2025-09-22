import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // dark background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(55),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Login",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                "Welcome back to Econance",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 35),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.green,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationColor: Colors.green,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Phone Number",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Text(
                "Email address",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 5),
              TextField(
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black, // text color
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(color: Colors.grey), // hint text style
                  labelText: 'someone@gmail.com',
                  labelStyle: TextStyle(color: Colors.grey),

                  // background color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // rounded corners
                    borderSide: BorderSide(color: Colors.grey, width: 5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey, width: 3),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green, width: 5),
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
