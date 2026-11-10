import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../../../domain/entities/post_entity.dart';
import '../../viewmodels/social_feed_viewmodel.dart';

class SharePostSheet extends StatelessWidget {
  final PostEntity post;

  const SharePostSheet({super.key, required this.post});

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
                'Share Post',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Post by ${post.authorName} (${post.authorRole})',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.link_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Copy Post Link & Excerpt',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Copies a shareable deep link and summary to your clipboard.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () async {
                  final text =
                      'OpenPro Insight by ${post.authorName}:\n"${post.content}"\nhttps://openpro.app/posts/${post.id}';
                  await Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppFeedback.showSuccess(
                      context,
                      'Post link copied to clipboard.',
                    );
                  }
                },
              ),
              const Divider(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.repeat_rounded,
                    color: colorScheme.tertiary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Instant Repost with Thoughts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Broadcasts to your network feed with attribution.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () async {
                  await context.read<SocialFeedViewModel>().repost(post.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppFeedback.showSuccess(
                      context,
                      'Post successfully reshared with your network.',
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
