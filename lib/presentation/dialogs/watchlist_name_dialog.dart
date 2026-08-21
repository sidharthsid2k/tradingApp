import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Dialog to create or rename a watchlist.
class WatchlistNameDialog extends StatefulWidget {
  const WatchlistNameDialog({
    required this.title,
    required this.confirmLabel,
    this.initialValue = '',
    super.key,
  });

  final String title;
  final String confirmLabel;
  final String initialValue;

  @override
  State<WatchlistNameDialog> createState() => _WatchlistNameDialogState();
}

class _WatchlistNameDialogState extends State<WatchlistNameDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, style: AppTextStyles.headingMedium),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          labelText: AppStrings.watchlistNameLabel,
          hintText: AppStrings.watchlistNameHint,
        ),
        textCapitalization: TextCapitalization.words,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel,
              style: AppTextStyles.buttonMedium
                  .copyWith(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel, style: AppTextStyles.buttonMedium),
        ),
      ],
    );
  }

  void _submit() {
    final name = _ctrl.text.trim();
    if (name.isNotEmpty) {
      Navigator.of(context).pop(name);
    }
  }
}
