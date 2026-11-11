import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../core/utils/resume_exporter.dart';
import '../../../domain/entities/skill_endorsement.dart';
import '../../../domain/entities/user_profile_entity.dart';

class ExportResumeDialog extends StatefulWidget {
  final UserProfileEntity profile;
  final List<SkillEndorsement>? endorsements;
  final Directory? targetDirectory; // Injected for deterministic testing

  const ExportResumeDialog({
    super.key,
    required this.profile,
    this.endorsements,
    this.targetDirectory,
  });

  @override
  State<ExportResumeDialog> createState() => _ExportResumeDialogState();
}

class _ExportResumeDialogState extends State<ExportResumeDialog> {
  final ResumeExporter _exporter = const ResumeExporter();
  final ScrollController _scrollController = ScrollController();
  int _selectedFormatIndex = 0; // 0 = Markdown (.md), 1 = Plain Text (.txt)
  bool _isExporting = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get _currentContent {
    if (_selectedFormatIndex == 0) {
      return _exporter.generateMarkdown(
        widget.profile,
        endorsements: widget.endorsements,
      );
    } else {
      return _exporter.generatePlainText(
        widget.profile,
        endorsements: widget.endorsements,
      );
    }
  }

  Future<void> _handleCopy() async {
    await _exporter.copyToClipboard(_currentContent);
    if (!mounted) return;
    AppFeedback.showSuccess(context, 'Executive resume copied to clipboard.');
  }

  Future<void> _handleExportFile() async {
    setState(() => _isExporting = true);
    try {
      final format = _selectedFormatIndex == 0 ? 'md' : 'txt';
      final file = await _exporter.exportResumeFile(
        widget.profile,
        format: format,
        endorsements: widget.endorsements,
        targetDirectory: widget.targetDirectory,
      );
      if (!mounted) return;
      final fileName = file.path.split(Platform.pathSeparator).last;
      AppFeedback.showSuccess(
        context,
        'Resume exported successfully: $fileName',
      );
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, 'Failed to export resume file: $e');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final content = _currentContent;
    final lineCount = content.split('\n').length;
    final charCount = content.length;

    return Dialog(
      backgroundColor: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 32 : 16,
        vertical: isLandscape ? 12 : 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 620,
          maxHeight: isLandscape ? 340 : 640,
        ),
        child: Padding(
          padding: EdgeInsets.all(isLandscape ? 12 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: isLandscape ? 18 : 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Executive Resume Exporter',
                          style: TextStyle(
                            fontSize: isLandscape ? 14 : 16,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'ATS-optimized markdown & plain text serialization',
                          style: TextStyle(
                            fontSize: isLandscape ? 10 : 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
              SizedBox(height: isLandscape ? 6 : 12),

              // Format Selector Tabs
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFormatTab(
                        label: 'Executive Markdown (.md)',
                        icon: Icons.code_rounded,
                        isSelected: _selectedFormatIndex == 0,
                        onTap: () => setState(() => _selectedFormatIndex = 0),
                        colorScheme: colorScheme,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildFormatTab(
                        label: 'Clean ASCII Text (.txt)',
                        icon: Icons.text_snippet_outlined,
                        isSelected: _selectedFormatIndex == 1,
                        onTap: () => setState(() => _selectedFormatIndex = 1),
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isLandscape ? 6 : 10),

              // Document Preview Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Preview Toolbar Meta
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedFormatIndex == 0
                                ? 'Markdown Output Preview'
                                : 'ASCII Document Preview',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            '$lineCount lines • $charCount characters',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Divider(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.6,
                        ),
                        height: 1,
                      ),
                      const SizedBox(height: 6),

                      // Scrollable Text Preview
                      Expanded(
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const ClampingScrollPhysics(),
                            child: Text(
                              content,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: isLandscape ? 10 : 11.5,
                                height: 1.45,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isLandscape ? 6 : 12),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _handleCopy,
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy to Clipboard'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? 12 : 16,
                        vertical: isLandscape ? 6 : 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isExporting ? null : _handleExportFile,
                    icon: _isExporting
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.download_rounded, size: 16),
                    label: Text(_isExporting ? 'Exporting...' : 'Save File'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? 12 : 16,
                        vertical: isLandscape ? 6 : 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: isSelected ? colorScheme.surfaceContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      elevation: isSelected ? 1 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
