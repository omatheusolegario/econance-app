# Econance

Seu sistema de gerenciamento financeiro individual e familiar.

## Sobre o projeto

Projeto de Conclusão do Curso Técnico em Desenvolvimento de Sistemas (ETEC), o Econance é um aplicativo multiplataforma (Flutter) para controle financeiro pessoal e familiar, com leitura automática de notas fiscais via OCR e insights financeiros gerados por IA. Apresentado na feira de projetos da escola, atraiu o maior público entre os TCCs do dia.

## Funcionalidades

- 📷 Leitura automática de notas fiscais e cupons fiscais via OCR, eliminando o lançamento manual de despesas
- 🤖 Insights financeiros com IA, com recomendações personalizadas a partir de padrões de gasto identificados automaticamente
- 📊 Gráficos e dashboards para visualização simplificada de onde e como o dinheiro está sendo gasto
- 👨‍👩‍👧‍👦 Suporte a contas individuais e familiares, com isolamento de dados por grupo de usuário
- ☁️ Backend em Firebase (Firestore) com regras de segurança em nuvem para controle de acesso read/write por grupo

## Tecnologias

- Flutter / Dart
- Firebase (Firestore, Cloud Security Rules)
- OCR para leitura de notas fiscais
- Multiplataforma: Android, iOS, Web, Windows, Linux, macOS

## Como rodar

```bash
flutter pub get
flutter run
```

> Requer configuração própria de Firebase (`firebase.json` já incluso no repositório) — adicione suas credenciais antes de rodar.

## Download

📱 APK funcional disponível na aba [Releases](../../releases) deste repositório

## Capturas de tela

## Autor

Desenvolvido e liderado por [Matheus Guimarães Olegario](https://github.com/omatheusolegario).

Desenvolvido também por Luiz Felipe Araújo Rodrigues, Rafael Arão Queiroz e Luana Marques de Nazaré.
