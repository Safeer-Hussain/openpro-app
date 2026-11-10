import 'package:flutter/material.dart';
import 'markdown_post_body.dart';

class MarkdownPostEditor extends StatefulWidget {
  final TextEditingController controller;
  final int maxLength;
  final int warningThreshold;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const MarkdownPostEditor({
    super.key,
    required this.controller,
    this.maxLength = 2000,
    this.warningThreshold = 1800,
    this.hintText = 'Share an architectural breakthrough, benchmark, or engineering lesson...',
    this.onChanged,
  });

  @override
  State<MarkdownPostEditor> createState() => _MarkdownPostEditorState();
}

class _MarkdownPostEditorState extends State<MarkdownPostEditor> {
  int _selectedTab = 0; // 0 = Edit, 1 = Preview

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    if (mounted) {
      setState(() {});
      widget.onChanged?.call(widget.controller.text);
    }
  }

  void _insertMarkdown(String prefix, String suffix, {String defaultText = ''}) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (selection.isValid && selection.start != selection.end) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(selection.start, selection.end, '$prefix$selectedText$suffix');
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start + prefix.length,
          extentOffset: selection.end + prefix.length,
        ),
      );
    } else {
      final start = selection.isValid ? selection.start : text.length;
      final inserted = '$prefix$defaultText$suffix';
      final newText = text.replaceRange(start, start, inserted);
      final newCursorPos = start + prefix.length + defaultText.length;
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorPos),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentLength = widget.controller.text.length;
    final isOverLimit = currentLength > widget.maxLength;
    final isNearLimit = currentLength >= widget.warningThreshold && !isOverLimit;

    Color counterColor = colorScheme.onSurfaceVariant;
    if (isOverLimit) {
      counterColor = colorScheme.error;
    } else if (isNearLimit) {
      counterColor = colorScheme.tertiary;
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverLimit ? colorScheme.error : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Mode Switcher Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                // Dual-mode Tab Selector
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModeButton(
                        context,
                        label: 'Edit',
                        icon: Icons.edit_note_rounded,
                        isSelected: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                        colorScheme: colorScheme,
                      ),
                      _buildModeButton(
                        context,
                        label: 'Preview',
                        icon: Icons.visibility_outlined,
                        isSelected: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Character counter
                Text(
                  '$currentLength / ${widget.maxLength}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isNearLimit || isOverLimit ? FontWeight.bold : FontWeight.w500,
                    color: counterColor,
                  ),
                ),
              ],
            ),
          ),

          // Markdown Action Toolbar (Visible in Edit mode)
          if (_selectedTab == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                border: Border(
                  bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildToolButton(
                      context,
                      tooltip: 'Bold',
                      icon: Icons.format_bold_rounded,
                      onPressed: () => _insertMarkdown('**', '**', defaultText: 'bold text'),
                      colorScheme: colorScheme,
                    ),
                    _buildToolButton(
                      context,
                      tooltip: 'Italic',
                      icon: Icons.format_italic_rounded,
                      onPressed: () => _insertMarkdown('*', '*', defaultText: 'italic text'),
                      colorScheme: colorScheme,
                    ),
                    _buildToolButton(
                      context,
                      tooltip: 'Header',
                      icon: Icons.title_rounded,
                      onPressed: () => _insertMarkdown('### ', '\n', defaultText: 'Section Title'),
                      colorScheme: colorScheme,
                    ),
                    _buildToolButton(
                      context,
                      tooltip: 'Bullet List',
                      icon: Icons.format_list_bulleted_rounded,
                      onPressed: () => _insertMarkdown('- ', '\n', defaultText: 'List item'),
                      colorScheme: colorScheme,
                    ),
                    _buildToolButton(
                      context,
                      tooltip: 'Code Block',
                      icon: Icons.code_rounded,
                      onPressed: () => _insertMarkdown('```dart\n', '\n```\n', defaultText: '// Code snippet'),
                      colorScheme: colorScheme,
                    ),
                    _buildToolButton(
                      context,
                      tooltip: 'Hyperlink',
                      icon: Icons.link_rounded,
                      onPressed: () => _insertMarkdown('[', '](https://example.com)', defaultText: 'Link Title'),
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            ),

          // Content Area
          if (_selectedTab == 0)
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextFormField(
                controller: widget.controller,
                maxLines: 7,
                minLines: 5,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 13.5,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(minHeight: 140),
              padding: const EdgeInsets.all(16),
              child: widget.controller.text.trim().isEmpty
                  ? Center(
                      child: Text(
                        'Markdown live preview will appear here as you type.',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    )
                  : MarkdownPostBody(text: widget.controller.text),
            ),

          // Warning message banner when over limit
          if (isOverLimit)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: colorScheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Character limit exceeded (maximum ${widget.maxLength} characters). Please shorten your post.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
    required ColorScheme colorScheme,
  }) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 17, color: colorScheme.onSurfaceVariant),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
    );
  }
}
