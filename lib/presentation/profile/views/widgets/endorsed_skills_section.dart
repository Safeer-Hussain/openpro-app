import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/skill_endorsement.dart';
import '../../viewmodels/profile_viewmodel.dart';

class EndorsedSkillsSection extends StatelessWidget {
  final List<SkillEndorsement>? endorsements;

  const EndorsedSkillsSection({super.key, this.endorsements});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, _) {
        final items = endorsements ?? viewModel.endorsements;

        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        final totalEndorsements = items.fold<int>(
          0,
          (sum, item) => sum + item.count,
        );

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Peer Skill Endorsements',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$totalEndorsements Endorsed',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) => Divider(
                  height: 16,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  final skill = items[index];
                  return _buildSkillItem(
                    context,
                    skill,
                    viewModel,
                    colorScheme,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkillItem(
    BuildContext context,
    SkillEndorsement skill,
    ProfileViewModel viewModel,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.skillName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${skill.count} ${skill.count == 1 ? "endorsement" : "endorsements"}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => viewModel.toggleEndorsement(skill.skillName),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: skill.isEndorsedByMe
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: skill.isEndorsedByMe
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      skill.isEndorsedByMe
                          ? Icons.check_circle_rounded
                          : Icons.add_circle_outline_rounded,
                      size: 14,
                      color: skill.isEndorsedByMe
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      skill.isEndorsedByMe ? 'Endorsed' : 'Endorse',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: skill.isEndorsedByMe
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (skill.topEndorsers.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildAvatarStack(
            context,
            skill.topEndorsers,
            skill.count,
            colorScheme,
          ),
        ],
      ],
    );
  }

  Widget _buildAvatarStack(
    BuildContext context,
    List<Endorser> endorsers,
    int totalCount,
    ColorScheme colorScheme,
  ) {
    const double avatarSize = 22.0;
    const double overlap = 14.0;
    final displayEndorsers = endorsers.take(4).toList();
    final remainingCount = totalCount - displayEndorsers.length;

    return Row(
      children: [
        SizedBox(
          height: avatarSize,
          width: (displayEndorsers.length * overlap) + (avatarSize - overlap),
          child: Stack(
            children: List.generate(displayEndorsers.length, (idx) {
              final endorser = displayEndorsers[idx];
              return Positioned(
                left: idx * overlap,
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surfaceContainer,
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      endorser.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: colorScheme.primaryContainer,
                        alignment: Alignment.center,
                        child: Text(
                          endorser.name.isNotEmpty ? endorser.name[0] : 'U',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            remainingCount > 0
                ? 'Endorsed by ${endorsers.first.name} and $remainingCount others'
                : 'Endorsed by ${endorsers.map((e) => e.name).join(", ")}',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontSize: 10.5, color: colorScheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
