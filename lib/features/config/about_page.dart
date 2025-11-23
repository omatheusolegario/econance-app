import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String _version = 'v1.0.0';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutUs)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: l10n.aboutUsFullText,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyMedium,
                h2: theme.textTheme.titleMedium,
                strong: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                blockSpacing: 12,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _version,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
