import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      "/welcome-page",
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          children: [
            const Text(
              "Você está na home, não se assuste, se quiser sair tem que limpar o cache ou apertar o botao de voltar Kkkkk",
            ),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context,"/revenues-expenses"), child: Text("REVENUESSS! (and expenses)"))
          ],
        ),
      ),
    );
  }
}
