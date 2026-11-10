import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/asset_paths.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../viewmodels/social_feed_viewmodel.dart';

class CreateStoryModal extends StatefulWidget {
  const CreateStoryModal({super.key});

  @override
  State<CreateStoryModal> createState() => _CreateStoryModalState();
}

class _CreateStoryModalState extends State<CreateStoryModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  String _selectedMedia = AssetPaths.storyFlutter;
  bool _isPublishing = false;

  final List<Map<String, String>> _templates = [
    {'title': 'Architecture Spotlight', 'path': AssetPaths.storyFlutter},
    {'title': 'AI Engine Update', 'path': AssetPaths.storyAi},
    {'title': 'DevOps & CI/CD', 'path': AssetPaths.storyDevops},
    {'title': 'Hiring Announcement', 'path': AssetPaths.storyHiring},
    {'title': 'Milestone Showcase', 'path': AssetPaths.storyMilestone},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPublishing = true);
    final vm = context.read<SocialFeedViewModel>();
    await vm.createStory(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      mediaUrl: _selectedMedia,
    );

    if (mounted) {
      setState(() => _isPublishing = false);
      Navigator.pop(context);
      AppFeedback.showSuccess(
        context,
        'Story published successfully to network.',
      );
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
                Text(
                  'Post Professional Story',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Story Headline *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Scaling Flutter to 4M MAU',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Headline is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  'Story Summary *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _subtitleController,
                  maxLines: 2,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    hintText:
                        'Key takeaway, metric, or architectural insight...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Summary is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Theme Background Template',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _templates.length,
                    itemBuilder: (context, index) {
                      final item = _templates[index];
                      final isSelected = _selectedMedia == item['path'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(item['title']!),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedMedia = item['path']!);
                            }
                          },
                        ),
                      );
                    },
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
                            'Publish Story (24h Live)',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
