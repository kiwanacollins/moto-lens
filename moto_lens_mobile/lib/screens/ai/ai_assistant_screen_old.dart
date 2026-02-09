import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/ai_chat_message.dart';
import '../../providers/ai_chat_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../styles/styles.dart';
import '../../widgets/offline_banner.dart';

/// Full-screen AI Assistant chat screen.
///
/// Professional conversational interface branded with Electric Blue,
/// featuring quick-action chips, typing indicators, chat history
/// persistence, and export/clear functionality.
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load persisted chat history on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiChatProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    context.read<AiChatProvider>().sendMessage(text);
    _scrollToBottom();
  }

  void _sendQuickAction(String text) {
    _controller.clear();
    context.read<AiChatProvider>().sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear chat?', style: AppTypography.h5),
        content: Text(
          'This will remove all messages from this conversation.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AiChatProvider>().clearChat();
            },
            child: Text(
              'Clear',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportChat() {
    final transcript = context.read<AiChatProvider>().exportTranscript();
    Share.share(transcript);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(child: _buildMessageList()),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // App bar
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.headerBar,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Assistant',
                style: AppTypography.h5.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Consumer<AiChatProvider>(
                builder: (_, provider, __) {
                  final isOnline = context
                      .watch<ConnectivityProvider>()
                      .isOnline;
                  return Text(
                    provider.isTyping
                        ? 'Typing…'
                        : isOnline
                        ? 'Online'
                        : 'Offline',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) {
            switch (value) {
              case 'clear':
                _clearChat();
                break;
              case 'export':
                _exportChat();
                break;
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.share_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Export transcript'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Clear chat', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Message list
  // ---------------------------------------------------------------------------

  Widget _buildMessageList() {
    return Consumer<AiChatProvider>(
      builder: (_, provider, __) {
        if (!provider.hasMessages && !provider.isTyping) {
          return _buildEmptyState();
        }

        // Auto-scroll when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            // Typing indicator as the last item while waiting
            if (index == provider.messages.length && provider.isTyping) {
              return _buildTypingIndicator();
            }
            return _buildBubble(provider.messages[index]);
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              size: 40,
              color: AppColors.electricBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'How can I help you today?',
            style: AppTypography.h4.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ask me anything about vehicle diagnostics, parts, or maintenance.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildQuickActions(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Quick action chips
  // ---------------------------------------------------------------------------

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        icon: Icons.build_outlined,
        label: 'Explain this part',
        prompt:
            'Explain what a catalytic converter does, how it works, and common failure symptoms.',
      ),
      _QuickAction(
        icon: Icons.warning_amber_outlined,
        label: 'Common issues',
        prompt:
            'What are the most common mechanical issues with German vehicles and how to diagnose them?',
      ),
      _QuickAction(
        icon: Icons.calendar_month_outlined,
        label: 'Maintenance schedule',
        prompt:
            'Give me a general maintenance schedule for a German vehicle — oil changes, brakes, timing chain, etc.',
      ),
      _QuickAction(
        icon: Icons.troubleshoot_outlined,
        label: 'Diagnostic help',
        prompt:
            'My check engine light is on. Walk me through the initial diagnostic steps.',
      ),
    ];

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      alignment: WrapAlignment.center,
      children: actions.map((a) => _buildQuickChip(a)).toList(),
    );
  }

  Widget _buildQuickChip(_QuickAction action) {
    return ActionChip(
      avatar: Icon(action.icon, size: 18, color: AppColors.electricBlue),
      label: Text(
        action.label,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppColors.surface,
      side: BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      onPressed: () => _sendQuickAction(action.prompt),
    );
  }

  // ---------------------------------------------------------------------------
  // Chat bubbles
  // ---------------------------------------------------------------------------

  Widget _buildBubble(AiChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _buildAvatar(isUser: false),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.electricBlue : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.carbonBlack.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTimestamp(message.timestamp),
                        style: AppTypography.bodySmall.copyWith(
                          color: isUser
                              ? Colors.white.withValues(alpha: 0.65)
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      if (message.isError) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.error_outline,
                          size: 14,
                          color: isUser
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.error,
                        ),
                      ],
                    ],
                  ),
                  if (message.isError)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxs),
                      child: GestureDetector(
                        onTap: () =>
                            context.read<AiChatProvider>().retryLastMessage(),
                        child: Text(
                          'Tap to retry',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.electricBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: AppSpacing.xs),
            _buildAvatar(isUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.electricBlue.withValues(alpha: 0.15)
            : AppColors.electricBlue,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Icon(
        isUser ? Icons.person_outline : Icons.psychology_outlined,
        size: 16,
        color: isUser ? AppColors.electricBlue : Colors.white,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Typing indicator
  // ---------------------------------------------------------------------------

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(isUser: false),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: const _BouncingDots(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Input area
  // ---------------------------------------------------------------------------

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _inputFocus,
              textInputAction: TextInputAction.send,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              minLines: 1,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Ask about diagnostics, parts, maintenance…',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textDisabled,
                ),
                filled: true,
                fillColor: AppColors.backgroundSecondary,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  borderSide: const BorderSide(
                    color: AppColors.electricBlue,
                    width: 1.5,
                  ),
                ),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Consumer<AiChatProvider>(
            builder: (_, provider, __) {
              return Material(
                color: AppColors.electricBlue,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                child: InkWell(
                  onTap: provider.isTyping ? null : _send,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: provider.isTyping
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// =============================================================================
// Private helper classes
// =============================================================================

/// Quick action definition.
class _QuickAction {
  final IconData icon;
  final String label;
  final String prompt;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.prompt,
  });
}

/// Animated three-dot typing indicator.
class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });

    _animations = _controllers.map((c) {
      return Tween<double>(
        begin: 0,
        end: -6,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    }).toList();

    // Stagger the starts
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) {
            return Transform.translate(
              offset: Offset(0, _animations[i].value),
              child: Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
