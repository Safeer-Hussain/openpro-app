import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MarkdownPostBody extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;

  const MarkdownPostBody({super.key, required this.text, this.baseStyle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultStyle =
        baseStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          height: 1.5,
          fontSize: 14,
        ) ??
        TextStyle(color: colorScheme.onSurface, height: 1.5, fontSize: 14);

    final blocks = _parseBlocks(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: blocks.map((block) {
        return _renderBlock(context, block, defaultStyle, colorScheme);
      }).toList(),
    );
  }

  List<_MdBlock> _parseBlocks(String input) {
    final List<_MdBlock> blocks = [];
    final lines = input.split('\n');

    bool inCodeBlock = false;
    String codeLanguage = '';
    final List<String> codeLines = [];
    final List<String> paragraphLines = [];

    void flushParagraph() {
      if (paragraphLines.isNotEmpty) {
        blocks.add(
          _MdBlock(
            type: _MdBlockType.paragraph,
            lines: List.from(paragraphLines),
          ),
        );
        paragraphLines.clear();
      }
    }

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.startsWith('```')) {
        if (inCodeBlock) {
          // Close code block
          blocks.add(
            _MdBlock(
              type: _MdBlockType.codeBlock,
              lines: List.from(codeLines),
              extra: codeLanguage,
            ),
          );
          codeLines.clear();
          inCodeBlock = false;
          codeLanguage = '';
        } else {
          // Open code block
          flushParagraph();
          inCodeBlock = true;
          codeLanguage = trimmed.substring(3).trim();
        }
        continue;
      }

      if (inCodeBlock) {
        codeLines.add(line);
        continue;
      }

      if (trimmed.startsWith('#')) {
        flushParagraph();
        blocks.add(_MdBlock(type: _MdBlockType.header, lines: [trimmed]));
        continue;
      }

      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        flushParagraph();
        blocks.add(
          _MdBlock(type: _MdBlockType.bullet, lines: [trimmed.substring(2)]),
        );
        continue;
      }

      if (trimmed.startsWith('> ')) {
        flushParagraph();
        blocks.add(
          _MdBlock(type: _MdBlockType.quote, lines: [trimmed.substring(2)]),
        );
        continue;
      }

      if (trimmed.isEmpty) {
        flushParagraph();
        continue;
      }

      paragraphLines.add(line);
    }

    flushParagraph();

    if (inCodeBlock && codeLines.isNotEmpty) {
      blocks.add(
        _MdBlock(
          type: _MdBlockType.codeBlock,
          lines: List.from(codeLines),
          extra: codeLanguage,
        ),
      );
    }

    return blocks;
  }

  Widget _renderBlock(
    BuildContext context,
    _MdBlock block,
    TextStyle defaultStyle,
    ColorScheme colorScheme,
  ) {
    switch (block.type) {
      case _MdBlockType.header:
        final raw = block.lines.first;
        int level = 0;
        while (level < raw.length && raw[level] == '#') {
          level++;
        }
        final content = raw.substring(level).trim();
        final double size = level == 1 ? 20.0 : (level == 2 ? 17.0 : 15.0);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            content,
            style: defaultStyle.copyWith(
              fontSize: size,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        );

      case _MdBlockType.bullet:
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 8, right: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: _buildRichInlineText(
                  block.lines.first,
                  defaultStyle,
                  colorScheme,
                ),
              ),
            ],
          ),
        );

      case _MdBlockType.quote:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: colorScheme.primary, width: 3.5),
            ),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(8),
            ),
          ),
          child: _buildRichInlineText(
            block.lines.first,
            defaultStyle.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
            colorScheme,
          ),
        );

      case _MdBlockType.codeBlock:
        final codeContent = block.lines.join('\n');
        final lang = block.extra?.isNotEmpty == true ? block.extra! : 'code';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: codeContent));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code snippet copied to clipboard.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.copy_rounded,
                              size: 13,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Copy',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  codeContent,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    height: 1.4,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );

      case _MdBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildRichInlineText(
            block.lines.join('\n'),
            defaultStyle,
            colorScheme,
          ),
        );
    }
  }

  Widget _buildRichInlineText(
    String text,
    TextStyle baseStyle,
    ColorScheme colorScheme,
  ) {
    final spans = _parseInlineSpans(text, baseStyle, colorScheme);
    return SelectableText.rich(TextSpan(children: spans), style: baseStyle);
  }

  List<InlineSpan> _parseInlineSpans(
    String text,
    TextStyle baseStyle,
    ColorScheme colorScheme,
  ) {
    final List<InlineSpan> spans = [];
    final regex = RegExp(
      r'(\*\*[^*]+\*\*)|(\*[^*]+\*)|(`[^`]+`)|(\[[^\]]+\]\([^)]+\))',
    );
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      final matchedText = match.group(0)!;
      if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
        // Bold
        spans.add(
          TextSpan(
            text: matchedText.substring(2, matchedText.length - 2),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (matchedText.startsWith('*') && matchedText.endsWith('*')) {
        // Italic
        spans.add(
          TextSpan(
            text: matchedText.substring(1, matchedText.length - 1),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      } else if (matchedText.startsWith('`') && matchedText.endsWith('`')) {
        // Inline code
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                matchedText.substring(1, matchedText.length - 1),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      } else if (matchedText.startsWith('[') && matchedText.contains('](')) {
        // Link [label](url)
        final closeBracket = matchedText.indexOf('](');
        final label = matchedText.substring(1, closeBracket);
        spans.add(
          TextSpan(
            text: label,
            style: TextStyle(
              color: colorScheme.primary,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return spans;
  }
}

enum _MdBlockType { header, bullet, quote, codeBlock, paragraph }

class _MdBlock {
  final _MdBlockType type;
  final List<String> lines;
  final String? extra;

  const _MdBlock({required this.type, required this.lines, this.extra});
}
