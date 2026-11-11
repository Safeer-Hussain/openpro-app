import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_feedback.dart';
import '../../domain/entities/inmail_message.dart';
import 'viewmodels/inmail_viewmodel.dart';

class InmailDetailView extends StatefulWidget {
  final String messageId;

  const InmailDetailView({super.key, required this.messageId});

  @override
  State<InmailDetailView> createState() => _InmailDetailViewState();
}

class _InmailDetailViewState extends State<InmailDetailView> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<InmailViewModel>();
      vm.markAsRead(widget.messageId);
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSendReply(InmailViewModel viewModel) async {
    final text = _replyController.text.trim();
    if (text.isEmpty) {
      AppFeedback.showWarning(context, 'Please enter a reply message.');
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await viewModel.sendReply(widget.messageId, text);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      _replyController.clear();
      _replyFocusNode.unfocus();
      AppFeedback.showSuccess(
        context,
        'Your response was sent to the recruiter.',
      );
    } else {
      AppFeedback.showError(
        context,
        viewModel.errorMessage ?? 'Failed to send response.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Consumer<InmailViewModel>(
      builder: (context, viewModel, _) {
        final message = viewModel.findMessage(widget.messageId);

        if (message == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('InMail Message')),
            body: Center(
              child: Text(
                'Message not found',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: isLandscape ? 40 : 56,
            title: Text(
              message.isRecruiter ? 'Recruiter InMail' : 'Direct Message',
              style: TextStyle(
                fontSize: isLandscape ? 15 : 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: message.isReplied
                      ? colorScheme.tertiaryContainer
                      : message.isUnread
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    message.isReplied
                        ? 'Replied'
                        : message.isUnread
                        ? 'Unread'
                        : 'Read',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: message.isReplied
                          ? colorScheme.onTertiaryContainer
                          : message.isUnread
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 24 : 16,
                vertical: isLandscape ? 8 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sender Card
                  _buildSenderCard(context, message, colorScheme),
                  const SizedBox(height: 12),

                  // Opportunity Card if available
                  if (message.opportunityTitle != null) ...[
                    _buildOpportunityCard(context, message, colorScheme),
                    const SizedBox(height: 12),
                  ],

                  // Message Subject & Body Card
                  _buildMessageContentCard(context, message, colorScheme),
                  const SizedBox(height: 16),

                  // Replied State or Reply Form
                  if (message.isReplied)
                    _buildRepliedBanner(context, message, colorScheme)
                  else
                    _buildReplyComposer(context, viewModel, colorScheme),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSenderCard(
    BuildContext context,
    InmailMessage message,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
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
          const SizedBox(width: 12),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (message.isRecruiter)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Verified Recruiter',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${message.senderRole} • ${message.senderCompany}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Received ${message.sentAt}',
                  style: TextStyle(fontSize: 11, color: colorScheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(
    BuildContext context,
    InmailMessage message,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_rounded,
              size: 20,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Opportunity',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  message.opportunityTitle ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (message.opportunitySalary != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    message.opportunitySalary!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContentCard(
    BuildContext context,
    InmailMessage message,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.subject,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 12),
          Text(
            message.body,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepliedBanner(
    BuildContext context,
    InmailMessage message,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'You replied to this outreach',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (message.repliedAt != null)
                Text(
                  message.repliedAt!,
                  style: TextStyle(fontSize: 11, color: colorScheme.outline),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message.replyContent ?? '',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyComposer(
    BuildContext context,
    InmailViewModel viewModel,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick-Reply Templates',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal scrollable quick-reply template chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: InmailViewModel.quickReplyTemplates.map((template) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      template,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    side: BorderSide(color: colorScheme.outlineVariant),
                    onPressed: () {
                      _replyController.text = template;
                      _replyController.selection = TextSelection.fromPosition(
                        TextPosition(offset: template.length),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Custom Reply Input
          TextField(
            controller: _replyController,
            focusNode: _replyFocusNode,
            maxLines: 4,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Type your response to the recruiter...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),

          // Submit Action Button
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () => _handleSendReply(viewModel),
              icon: _isSubmitting
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 16),
              label: Text(_isSubmitting ? 'Sending...' : 'Send Response'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
