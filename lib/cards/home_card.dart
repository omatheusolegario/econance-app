import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color? subtitleColor;
  final Color? backgroundColor;
  final IconData? icon;
  final Color? iconColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.subtitleColor,
    this.backgroundColor,
    this.icon,
    this.iconColor,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doubleValue = double.tryParse(value) ?? 0.0;

    final cardColor = isSelected
        ? theme.primaryColor.withOpacity(0.2)
        : backgroundColor ?? theme.cardColor.withOpacity(0.05);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, color: iconColor, size: 20),
                if (icon != null) const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "R\$ ${doubleValue.toStringAsFixed(2)}",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: subtitleColor ?? theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
