import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_feedback.dart';
import '../viewmodels/ai_assistant_viewmodel.dart';
import 'widgets/chat_bubble.dart';

class AiCareerAssistantView extends StatefulWidget {
  const AiCareerAssistantView({super.key});

  @override
  State<AiCareerAssistantView> createState() => _AiCareerAssistantViewState();
}

class _AiCareerAssistantViewState extends State<AiCareerAssistantView> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend([String? text]) {
    final query = text ?? _inputController.text;
    if (query.trim().isEmpty) return;

    _inputController.clear();
    final vm = context.read<AiAssistantViewModel>();
    vm.sendMessage(query);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Consumer<AiAssistantViewModel>(
        builder: (context, vm, _) {
          _scrollToBottom();

          return Column(
            children: [
              // Assistant Header Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.psychology_rounded,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OpenPro On-Device Intelligence',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Local Career Graph • Zero Cloud Latency',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                      tooltip: 'Clear Chat History',
                      onPressed: () {
                        vm.clearChat();
                        AppFeedback.showInfo(context, 'Chat history cleared.');
                      },
                    ),
                  ],
                ),
              ),

              // Quick Action Chips Header
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  border: Border(
                    bottom: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: AiAssistantViewModel.defaultActionChips.map((
                    chipText,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: Icon(
                          Icons.bolt_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        label: Text(chipText),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        backgroundColor: colorScheme.surfaceContainer,
                        side: BorderSide(color: colorScheme.outlineVariant),
                        onPressed: vm.isStreaming
                            ? null
                            : () => _handleSend(chipText),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Chat Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  itemCount: vm.messages.length + (vm.isStreaming ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < vm.messages.length) {
                      final msg = vm.messages[index];
                      return ChatBubble(
                        message: msg,
                        onChipTapped: (chip) => _handleSend(chip),
                      );
                    }

                    // Active streaming token card
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainer,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(18),
                                ),
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (vm.transientStatus.isNotEmpty) ...[
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          vm.transientStatus,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  if (vm.currentStreamingText.isNotEmpty)
                                    Text(
                                      vm.currentStreamingText,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        height: 1.45,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Input Bar
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      top: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (val) => _handleSend(val),
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Ask about career matches, resume gaps, or pitch...',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            fillColor: colorScheme.surfaceContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        icon: vm.isStreaming
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.arrow_upward_rounded, size: 20),
                        onPressed: vm.isStreaming ? null : () => _handleSend(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
