import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportDialog extends StatefulWidget {
  final int noteId;

  const ReportDialog({super.key, required this.noteId});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _reportReasons = [];
  int? _selectedReasonId;
  final _customTextController = TextEditingController();
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadReportReasons();
  }

  @override
  void dispose() {
    _customTextController.dispose();
    super.dispose();
  }

  Future<void> _loadReportReasons() async {
    try {
      final reasons = await _apiService.getReportReasons();
      setState(() {
        _reportReasons = reasons;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load report reasons: $e')),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (_selectedReasonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason')),
      );
      return;
    }

    // Check if "Other" is selected and custom text is required
    final selectedReason = _reportReasons.firstWhere(
      (r) => r['id'] == _selectedReasonId,
      orElse: () => {},
    );

    if (selectedReason['reasonText'] == 'Other' &&
        _customTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide details for "Other"')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await _apiService.submitReport(widget.noteId, _selectedReasonId!);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit report: $e')),
        );
      }
    }
  }

  bool _isOtherSelected() {
    if (_selectedReasonId == null) return false;
    final selectedReason = _reportReasons.firstWhere(
      (r) => r['id'] == _selectedReasonId,
      orElse: () => {},
    );
    return selectedReason['reasonText'] == 'Other';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Report Note',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: _loading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why are you reporting this note?',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedReasonId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    hint: const Text('Select a reason...'),
                    items: _reportReasons.map((reason) {
                      return DropdownMenuItem<int>(
                        value: reason['id'],
                        child: Text(reason['reasonText']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedReasonId = value;
                        if (!_isOtherSelected()) {
                          _customTextController.clear();
                        }
                      });
                    },
                  ),
                  if (_isOtherSelected()) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Please provide details:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customTextController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe the issue...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
