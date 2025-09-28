import 'package:flutter/material.dart';

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return  Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        actions: [
        ],
        title: const Text("Config"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const Text(
                "Você está na home, não se assuste, se quiser sair tem que limpar o cache ou apertar o botao de voltar Kkkkk",
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, "/revenues-expenses"),
                child: const Text("Revenues-expenses"),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, "/add-category"),
                child: const Text("Category"),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
