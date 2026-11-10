import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../../../domain/entities/event_entity.dart';
import '../../viewmodels/community_viewmodel.dart';

class EventCard extends StatelessWidget {
  final EventEntity event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final vm = context.read<CommunityViewModel>();

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
          // Header with Organizer & Virtual Badge
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(event.organizerLogo),
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  event.organizer,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: event.isVirtual
                      ? colorScheme.primaryContainer
                      : colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      event.isVirtual
                          ? Icons.videocam_rounded
                          : Icons.location_on_rounded,
                      size: 12,
                      color: event.isVirtual
                          ? colorScheme.primary
                          : colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.isVirtual ? 'Virtual' : 'In-Person',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: event.isVirtual
                            ? colorScheme.primary
                            : colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            event.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Date & Location
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                event.dateDescription,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.pin_drop_outlined,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.locationOrLink,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Speaker Lineup Chips
          if (event.speakers.isNotEmpty) ...[
            Text(
              'Featured Keynotes:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: event.speakers.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          const Divider(height: 1),
          const SizedBox(height: 12),

          // Footer: Attendees Count & RSVP Button
          Row(
            children: [
              Icon(
                Icons.how_to_reg_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${event.attendeeCount} registered executives',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: event.isRsvp
                      ? colorScheme.tertiary
                      : colorScheme.primary,
                  foregroundColor: event.isRsvp
                      ? colorScheme.onTertiary
                      : colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                icon: Icon(
                  event.isRsvp
                      ? Icons.check_circle_rounded
                      : Icons.event_available_rounded,
                  size: 16,
                ),
                label: Text(
                  event.isRsvp ? 'Attending' : '1-Tap RSVP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () {
                  vm.toggleRsvpEvent(event.id);
                  AppFeedback.showSuccess(
                    context,
                    event.isRsvp
                        ? 'Cancelled RSVP for ${event.title}'
                        : 'Registration confirmed for ${event.title}',
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
