import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/asset_paths.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../viewmodels/social_feed_viewmodel.dart';
import 'markdown_post_editor.dart';

class CreatePostModal extends StatefulWidget {
  const CreatePostModal({super.key});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _codeController = TextEditingController();
  final _tagsController = TextEditingController(
    text: '#Flutter #Architecture #CleanCode',
  );
  bool _includeCode = false;
  bool _isPublishing = false;

  @override
  void dispose() {
    _contentController.dispose();
    _codeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      AppFeedback.showError(context, 'Post content cannot be empty.');
      return;
    }
    if (content.length < 10) {
      AppFeedback.showError(context, 'Please share at least 10 characters.');
      return;
    }
    if (content.length > 2000) {
      AppFeedback.showError(
        context,
        'Post exceeds maximum limit of 2,000 characters.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPublishing = true);
    final vm = context.read<SocialFeedViewModel>();

    final rawTags = _tagsController.text
        .split(' ')
        .where((t) => t.trim().isNotEmpty)
        .map((t) => t.startsWith('#') ? t : '#$t')
        .toList();

    await vm.createPost(
      content: content,
      codeSnippet: _includeCode && _codeController.text.trim().isNotEmpty
          ? _codeController.text.trim()
          : null,
      codeLanguage: _includeCode ? 'dart' : null,
      tags: rawTags,
    );

    if (mounted) {
      setState(() => _isPublishing = false);
      Navigator.pop(context);
      AppFeedback.showSuccess(context, 'Post published to OpenPro Network.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(AssetPaths.safeerAvatar),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Safeer Hussain',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Posting to Professional Feed',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MarkdownPostEditor(controller: _contentController),
                const SizedBox(height: 12),

                // Toggle Code Snippet
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Attach Code Snippet',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  value: _includeCode,
                  onChanged: (val) => setState(() => _includeCode = val),
                ),
                if (_includeCode) ...[
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _codeController,
                    maxLines: 4,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                    decoration: const InputDecoration(
                      hintText: '// Paste Dart, SQL, or architectural snippet here...',
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Hashtags',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _tagsController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    hintText: '#Flutter #DevOps #SystemDesign',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isPublishing ? null : _submit,
                    child: _isPublishing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Text(
                            'Publish Post',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
