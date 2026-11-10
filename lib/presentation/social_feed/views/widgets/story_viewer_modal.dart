import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../../../domain/entities/story_entity.dart';
import '../../viewmodels/social_feed_viewmodel.dart';

class StoryViewerModal extends StatefulWidget {
  final List<StoryEntity> stories;
  final int initialIndex;

  const StoryViewerModal({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerModal> createState() => _StoryViewerModalState();
}

class _StoryViewerModalState extends State<StoryViewerModal>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animController;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animController = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: widget.stories[_currentIndex].durationSeconds,
      ),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _animController.duration = Duration(
          seconds: widget.stories[_currentIndex].durationSeconds,
        );
        _animController.reset();
        _animController.forward();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _animController.duration = Duration(
          seconds: widget.stories[_currentIndex].durationSeconds,
        );
        _animController.reset();
        _animController.forward();
      });
    } else {
      _animController.reset();
      _animController.forward();
    }
  }

  void _pause() {
    if (!_isPaused) {
      _isPaused = true;
      _animController.stop();
    }
  }

  void _resume() {
    if (_isPaused) {
      _isPaused = false;
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < width * 0.3) {
            _previousStory();
          } else if (details.localPosition.dx > width * 0.7) {
            _nextStory();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Story Media
            Image.asset(story.mediaUrl, fit: BoxFit.cover),

            // Top Gradient & Bottom Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.4, 0.85],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Safe Area Controls
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segmented Progress Bars
                    Row(
                      children: List.generate(widget.stories.length, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, _) {
                                double value = 0.0;
                                if (index < _currentIndex) {
                                  value = 1.0;
                                } else if (index == _currentIndex) {
                                  value = _animController.value;
                                }
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: value,
                                    minHeight: 3,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.3,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),

                    // Author Header Row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage(story.authorAvatar),
                          backgroundColor: Colors.white24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                story.authorName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                story.postedAt,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Story Text Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            story.subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Reactions Row (All Vector Material Icons)
                    Row(
                      children: [
                        _buildReactionButton(
                          Icons.thumb_up_alt_rounded,
                          'Like',
                          story.id,
                        ),
                        const SizedBox(width: 10),
                        _buildReactionButton(
                          Icons.lightbulb_rounded,
                          'Insightful',
                          story.id,
                        ),
                        const SizedBox(width: 10),
                        _buildReactionButton(
                          Icons.favorite_rounded,
                          'Appreciate',
                          story.id,
                        ),
                        const SizedBox(width: 10),
                        _buildReactionButton(
                          Icons.rocket_launch_rounded,
                          'Inspiring',
                          story.id,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton(IconData icon, String label, String storyId) {
    return Expanded(
      child: InkWell(
        onTap: () {
          context.read<SocialFeedViewModel>().reactToStory(storyId);
          AppFeedback.showSuccess(context, 'Reaction sent: $label');
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
