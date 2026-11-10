import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/social_feed_viewmodel.dart';
import 'widgets/create_post_modal.dart';
import 'widgets/post_card.dart';
import 'widgets/stories_bar.dart';

class SocialFeedView extends StatelessWidget {
  const SocialFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_create_post',
        icon: const Icon(Icons.edit_note_rounded, size: 20),
        label: const Text(
          'Post Insight',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const CreatePostModal(),
          );
        },
      ),
      body: Consumer<SocialFeedViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = vm.posts;
          final stories = vm.stories;

          if (isLandscape) {
            return Row(
              children: [
                // Left stories sidebar
                SizedBox(
                  width: 240,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Text(
                            'Network Stories',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Expanded(child: StoriesBar(stories: stories)),
                      ],
                    ),
                  ),
                ),

                // Right feed
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(post: posts[index]);
                    },
                  ),
                ),
              ],
            );
          }

          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: StoriesBar(stories: stories)),
              SliverPadding(
                padding: const EdgeInsets.only(top: 6, bottom: 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return PostCard(post: posts[index]);
                  }, childCount: posts.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
