import 'package:flutter/material.dart';

import '../../../../domain/entities/story_entity.dart';
import 'create_story_modal.dart';
import 'story_viewer_modal.dart';

class StoriesBar extends StatelessWidget {
  final List<StoryEntity> stories;

  const StoriesBar({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryButton(context, colorScheme);
          }
          final story = stories[index - 1];
          return _buildStoryItem(context, story, index - 1, colorScheme);
        },
      ),
    );
  }

  Widget _buildAddStoryButton(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const CreateStoryModal(),
          );
        },
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 2,
                    ),
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  child: const Center(
                    child: Icon(Icons.person_rounded, size: 30),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 14,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Add Story',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(
    BuildContext context,
    StoryEntity story,
    int storyIndex,
    ColorScheme colorScheme,
  ) {
    final hasUnviewed = !story.isViewed;

    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, _, _) =>
                  StoryViewerModal(stories: stories, initialIndex: storyIndex),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasUnviewed
                    ? LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                          colorScheme.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: hasUnviewed ? null : colorScheme.outlineVariant,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surface,
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(story.authorAvatar),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 64,
              child: Text(
                story.authorName.split(' ').first,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: hasUnviewed ? FontWeight.w700 : FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
