import 'package:econance/features/ocr/pages/invoice_capture.dart';
import 'package:flutter/material.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Scan your NF and",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white60,
                  ),
                ),
                Text(
                  "Categorize your purchases",
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
                  width: MediaQuery.widthOf(context)/1.8,
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
                label: Text("Add Bill"),
                icon: Icon(Icons.add),
                iconAlignment: IconAlignment.start,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
