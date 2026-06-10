import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bug_report_service.dart';

class BugReportBottomSheet extends StatefulWidget {
  const BugReportBottomSheet({super.key});

  @override
  State<BugReportBottomSheet> createState() => _BugReportBottomSheetState();
}

class _BugReportBottomSheetState extends State<BugReportBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedSeverity = 'medium';
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  final List<String> _severityOptions = ['low', 'medium', 'high', 'critical'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitBugReport() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final bugReportService = context.read<BugReportService>();
      await bugReportService.submitBugReport(
        title: _titleController.text,
        description: _descriptionController.text,
        severity: _selectedSeverity,
      );

      setState(() => _successMessage = 'Bug report submitted successfully!');
      
      // Auto-close after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      setState(() => _errorMessage = 'Failed to submit: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Report a Bug', style: theme.textTheme.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title Field
            Text('Title', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: 'Brief description of the bug',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),

            // Description Field
            Text('Description', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'Please provide detailed steps to reproduce...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),

            // Severity Dropdown
            Text('Severity', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _selectedSeverity,
              items: _severityOptions
                  .map((severity) => DropdownMenuItem(
                        value: severity,
                        child: Text(severity.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSeverity = value!),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  border: Border.all(color: theme.colorScheme.error),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),

            // Success Message
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  border: Border.all(color: theme.colorScheme.tertiary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _successMessage!,
                  style: TextStyle(color: theme.colorScheme.tertiary),
                ),
              ),

            if (_errorMessage != null || _successMessage != null)
              const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBugReport,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Bug Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
