import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: const Padding(padding: EdgeInsets.all(30.0), child: Column(children: [const Text("Você está na home, não se assuste, se quiser sair tem que limpar o cache ou apertar o botao de voltar Kkkkk")]))
    );
  }
}
