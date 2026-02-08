import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/ai_chat_message.dart';
import '../../providers/ai_chat_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../styles/styles.dart';
import '../../widgets/formatted_markdown.dart';
import '../../widgets/offline_banner.dart';

/// General automotive chat screen.
///
/// Text-only conversational interface for asking questions about cars,
/// spare parts, repairs, diagnostics, and maintenance. Uses the existing
/// [AiChatProvider] and persists history via SharedPreferences.
class GeneralChatScreen extends StatefulWidget {
  const GeneralChatScreen({super.key});

  @override
  State<GeneralChatScreen> createState() => _GeneralChatScreenState();
}

class _GeneralChatScreenState extends State<GeneralChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
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

  // --------------------------------------------------------------------------
  // Actions
  // --------------------------------------------------------------------------

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
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

  // --------------------------------------------------------------------------
  // Build
  // --------------------------------------------------------------------------

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

  // --------------------------------------------------------------------------
  // App bar
  // --------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.electricBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: const Icon(
              Icons.chat_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'General Chat',
                style: AppTypography.h5.copyWith(
                  color: Colors.white,
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
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        // New chat button
        IconButton(
          icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
          tooltip: 'New Chat',
          onPressed: _startNewChat,
        ),
        // History button
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          tooltip: 'Chat History',
          onPressed: _showChatHistory,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
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

  // --------------------------------------------------------------------------
  // Session management
  // --------------------------------------------------------------------------

  void _startNewChat() {
    context.read<AiChatProvider>().createNewChat();
    _controller.clear();
  }

  void _showChatHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, scrollController) {
          return Consumer<AiChatProvider>(
            builder: (_, provider, __) {
              final sessions = provider.sessions;

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history,
                          color: AppColors.electricBlue,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Chat History',
                          style: AppTypography.h5.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: sessions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 48,
                                  color: AppColors.textDisabled,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'No chat history yet',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            itemCount: sessions.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: AppColors.border),
                            itemBuilder: (ctx, index) {
                              final session = sessions[index];
                              final isActive =
                                  provider.activeSession?.id == session.id;

                              return Dismissible(
                                key: Key(session.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: AppColors.error,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.lg,
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (_) async {
                                  return await showDialog<bool>(
                                        context: ctx,
                                        builder: (dialogCtx) => AlertDialog(
                                          title: Text(
                                            'Delete chat?',
                                            style: AppTypography.h5,
                                          ),
                                          content: Text(
                                            'This will permanently delete this conversation.',
                                            style: AppTypography.bodyMedium,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                dialogCtx,
                                                false,
                                              ),
                                              child: Text(
                                                'Cancel',
                                                style: AppTypography
                                                    .buttonMedium
                                                    .copyWith(
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                dialogCtx,
                                                true,
                                              ),
                                              child: Text(
                                                'Delete',
                                                style: AppTypography
                                                    .buttonMedium
                                                    .copyWith(
                                                      color: AppColors.error,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ) ??
                                      false;
                                },
                                onDismissed: (_) {
                                  provider.deleteSession(session.id);
                                },
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppColors.electricBlue.withValues(
                                              alpha: 0.15,
                                            )
                                          : AppColors.backgroundSecondary,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSmall,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.chat_bubble_outline,
                                      size: 20,
                                      color: isActive
                                          ? AppColors.electricBlue
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  title: Text(
                                    session.title,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: isActive
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    session.preview,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: isActive
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.electricBlue
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusSmall,
                                            ),
                                          ),
                                          child: Text(
                                            'Active',
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color: AppColors.electricBlue,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        )
                                      : null,
                                  onTap: () {
                                    provider.switchToSession(session.id);
                                    Navigator.pop(ctx);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Message list
  // --------------------------------------------------------------------------

  Widget _buildMessageList() {
    return Consumer<AiChatProvider>(
      builder: (_, provider, __) {
        if (!provider.hasMessages && !provider.isTyping) {
          return _buildEmptyState();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.messages.length && provider.isTyping) {
              return _buildTypingIndicator();
            }
            return _buildBubble(provider.messages[index]);
          },
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // Empty state
  // --------------------------------------------------------------------------

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
              Icons.chat_outlined,
              size: 40,
              color: AppColors.electricBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Ask a General Question',
            style: AppTypography.h4.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ask me anything about cars, spare parts, repairs, '
            'diagnostics, and maintenance.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Chat bubbles
  // --------------------------------------------------------------------------

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
                  if (isUser)
                    SelectableText(
                      message.content,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        height: 1.5,
                      ),
                    )
                  else
                    FormattedMarkdown(
                      data: message.content,
                      textColor: AppColors.textPrimary,
                      accentColor: AppColors.electricBlue,
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

  // --------------------------------------------------------------------------
  // Typing indicator
  // --------------------------------------------------------------------------

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

  // --------------------------------------------------------------------------
  // Input area
  // --------------------------------------------------------------------------

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
                hintText: 'Ask about cars, parts, repairs…',
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

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
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
