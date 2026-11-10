import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../domain/entities/post_entity.dart';
import '../../viewmodels/social_feed_viewmodel.dart';
import 'comments_bottom_sheet.dart';
import 'markdown_post_body.dart';
import 'share_post_sheet.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final vm = context.read<SocialFeedViewModel>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(post.authorAvatar),
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded, size: 14, color: colorScheme.primary),
                      ],
                    ),
                    Text(
                      '${post.authorRole} • ${post.authorCompany}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                post.timestamp,
                style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          MarkdownPostBody(text: post.content),
          const SizedBox(height: 10),

          // Code Snippet Block (if any)
          if (post.codeSnippet != null && post.codeSnippet!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code_rounded, size: 14, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        (post.codeLanguage ?? 'snippet').toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.copy_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: post.codeSnippet!));
                          if (context.mounted) {
                            AppFeedback.showSuccess(context, 'Code snippet copied to clipboard.');
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      post.codeSnippet!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        height: 1.4,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Hashtags
          if (post.tags.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: post.tags.map((tag) {
                return Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          const Divider(height: 1),
          const SizedBox(height: 6),

          // Action Toolbar (Like, Comment, Repost, Bookmark, Share)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 100% Reactive Like Button
              InkWell(
                onTap: () => vm.toggleLike(post.id),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: post.isLiked ? colorScheme.error : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likesCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: post.isLiked ? colorScheme.error : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Comment Button
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => CommentsBottomSheet(postId: post.id),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 17, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        '${post.commentsCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Repost Button
              InkWell(
                onTap: () => vm.repost(post.id),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.repeat_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        '${post.sharesCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bookmark Button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  post.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  size: 18,
                  color: post.isBookmarked ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
                onPressed: () => vm.toggleBookmark(post.id),
              ),

              // Share Button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.share_outlined, size: 18, color: colorScheme.onSurfaceVariant),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => SharePostSheet(post: post),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
