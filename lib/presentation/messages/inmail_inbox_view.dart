import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/inmail_message.dart';
import 'inmail_detail_view.dart';
import 'viewmodels/inmail_viewmodel.dart';

class InmailInboxView extends StatelessWidget {
  const InmailInboxView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Consumer<InmailViewModel>(
      builder: (context, viewModel, _) {
        final currentMessages = viewModel.currentMessages;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: isLandscape ? 40 : 56,
            title: Text(
              'InMail & Messages',
              style: TextStyle(
                fontSize: isLandscape ? 15 : 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => viewModel.loadMessages(),
              ),
            ],
          ),
          body: Column(
            children: [
              // Segmented Category Tabs
              _buildSegmentedTabs(context, viewModel, colorScheme),

              // Message List or Empty State
              Expanded(
                child: viewModel.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      )
                    : currentMessages.isEmpty
                    ? _buildEmptyState(context, viewModel, colorScheme)
                    : RefreshIndicator(
                        onRefresh: () => viewModel.loadMessages(),
                        color: colorScheme.primary,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: isLandscape ? 24 : 12,
                            vertical: 12,
                          ),
                          itemCount: currentMessages.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final message = currentMessages[index];
                            return _buildMessageCard(
                              context,
                              message,
                              viewModel,
                              colorScheme,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegmentedTabs(
    BuildContext context,
    InmailViewModel viewModel,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              context: context,
              label: 'Recruiter Outreach',
              unreadCount: viewModel.unreadRecruiterCount,
              isSelected: viewModel.selectedTabIndex == 0,
              icon: Icons.shield_outlined,
              selectedIcon: Icons.shield_rounded,
              onTap: () => viewModel.setTabIndex(0),
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton(
              context: context,
              label: 'General',
              unreadCount: viewModel.unreadGeneralCount,
              isSelected: viewModel.selectedTabIndex == 1,
              icon: Icons.chat_bubble_outline_rounded,
              selectedIcon: Icons.chat_bubble_rounded,
              onTap: () => viewModel.setTabIndex(1),
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required String label,
    required int unreadCount,
    required bool isSelected,
    required IconData icon,
    required IconData selectedIcon,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: isSelected ? colorScheme.surfaceContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      elevation: isSelected ? 1 : 0,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                size: 16,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(
    BuildContext context,
    InmailMessage message,
    InmailViewModel viewModel,
    ColorScheme colorScheme,
  ) {
    return Material(
      color: message.isUnread
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InmailDetailView(messageId: message.id),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: message.isUnread
                  ? colorScheme.primary.withValues(alpha: 0.35)
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Avatar, Sender info, Status Chip
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    backgroundImage: AssetImage(message.senderAvatar),
                    onBackgroundImageError: (error, stackTrace) {},
                    child: message.senderAvatar.isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            color: colorScheme.onSurfaceVariant,
                          )
                        : null,
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
                                message.senderName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (message.isUnread) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${message.senderRole} • ${message.senderCompany}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(message, colorScheme),
                ],
              ),
              const SizedBox(height: 8),

              // Opportunity Pill if available
              if (message.opportunityTitle != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        size: 12,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${message.opportunityTitle} (${message.opportunitySalary ?? ''})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],

              // Subject
              Text(
                message.subject,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: message.isUnread
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),

              // Snippet Preview
              Text(
                message.body,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Footer: Sent Time & Reply Preview if replied
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    message.sentAt,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.outline,
                    ),
                  ),
                  if (message.isReplied)
                    Row(
                      children: [
                        Icon(
                          Icons.reply_all_rounded,
                          size: 13,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Replied',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(InmailMessage message, ColorScheme colorScheme) {
    if (message.isReplied) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Replied',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: colorScheme.onTertiaryContainer,
          ),
        ),
      );
    }

    if (message.isUnread) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Unread',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Read',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    InmailViewModel viewModel,
    ColorScheme colorScheme,
  ) {
    final isRecruiter = viewModel.selectedTabIndex == 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRecruiter
                    ? Icons.shield_outlined
                    : Icons.mail_outline_rounded,
                size: 36,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isRecruiter
                  ? 'No Inbound Recruiter Outreach'
                  : 'No Direct Messages',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isRecruiter
                  ? 'When technical recruiters and hiring managers reach out regarding executive roles, their messages appear here.'
                  : 'Direct peer messages and community communications will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
