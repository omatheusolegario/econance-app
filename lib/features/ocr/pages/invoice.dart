import 'package:econance/features/ocr/pages/invoice_capture.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:econance/theme/responsive_colors.dart';
import 'package:shimmer/shimmer.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simula um carregamento de 800ms para efeito de shimmer
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Widget _buildShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = ResponsiveColors.greyShade(theme, 300);
    final highlightColor = theme.brightness == Brightness.dark ? Colors.grey[600]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 180, height: 16, color: baseColor),
              const SizedBox(height: 8),
              Container(width: 220, height: 28, color: baseColor),
            ],
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 1.8,
              height: MediaQuery.of(context).size.width / 1.8,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: _isLoading
            ? _buildShimmer(context)
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.scanYourNF,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ResponsiveColors.whiteOpacity(theme, 0.6),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.categorizeYourPurchases,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/invoice.png',
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width / 1.8,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InvoiceCapturePage(),
                  ),
                ),
                label: Text(AppLocalizations.of(context)!.addBill),
                icon: const Icon(Icons.add),
                iconAlignment: IconAlignment.start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
