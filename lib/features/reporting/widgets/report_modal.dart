import 'package:flutter/material.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';

class ReportModal extends StatefulWidget {
  const ReportModal({required this.reportedPlayerId, super.key});

  final String reportedPlayerId;

  @override
  State<ReportModal> createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  static const List<String> _categories = <String>[
    'harassment',
    'hate',
    'spam',
    'cheating',
    'inappropriate_content',
    'other',
  ];

  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String? category = _selectedCategory;
    if (category == null || _isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await SupabaseService.invokeFunction(
        SupabaseConstants.fnSubmitPlayerReport,
        body: <String, dynamic>{
          'reported_player_id': widget.reportedPlayerId,
          'category': category,
          'description': _descriptionController.text.trim(),
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = _reportErrorMessage(error.toString());
      });
    }
  }

  String _reportErrorMessage(String message) {
    if (message.contains('REPORT_RATE_LIMITED')) {
      return 'You recently reported this player. Our moderation team has it.';
    }
    if (message.contains('REPORT_DAILY_LIMIT')) {
      return 'Your daily report limit has been reached.';
    }
    return 'Report failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.obsidianCard,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24.0,
            24.0,
            24.0,
            MediaQuery.viewInsetsOf(context).bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Report Player',
                style: TextStyle(
                  color: AppColors.ivory,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: <Widget>[
                  for (final String category in _categories)
                    ChoiceChip(
                      label: Text(category.replaceAll('_', ' ').toUpperCase()),
                      selected: _selectedCategory == category,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                    ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                maxLength: 1000,
                style: const TextStyle(color: AppColors.ivory),
                decoration: const InputDecoration(
                  hintText: 'Add context',
                  hintStyle: TextStyle(color: AppColors.grey400),
                ),
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 12.0),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 16.0),
              FilledButton(
                onPressed:
                    _selectedCategory == null || _isSubmitting ? null : _submit,
                child: Text(_isSubmitting ? 'SUBMITTING' : 'SUBMIT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
