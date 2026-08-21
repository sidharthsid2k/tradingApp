import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Shows an illustrated empty state with title and subtitle.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.actionLabel,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBg, AppColors.secondaryBg],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            )
                .animate()
                .scale(begin: const Offset(0.8, 0.8), duration: 400.ms)
                .fadeIn(),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.headingMedium,
              textAlign: TextAlign.center,
            ).animate().slideY(begin: 0.2, duration: 350.ms, delay: 100.ms).fadeIn(),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ).animate().slideY(begin: 0.2, duration: 350.ms, delay: 150.ms).fadeIn(),
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: action,
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionLabel!),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ],
        ),
      ),
    );
  }
}
