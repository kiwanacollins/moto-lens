import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/ai_chat_message.dart';
import '../../services/api_service.dart';
import '../../styles/styles.dart';
import '../../widgets/offline_banner.dart';

/// Chat screen for scanning a car part image and asking follow-up questions.
///
/// Flow:
///   1. User captures / picks an image (camera or gallery).
///   2. The image is sent to `/api/parts/scan` for initial Gemini Vision
///      analysis.
///   3. The analysis is displayed in a chat bubble.
///   4. The user can type follow-up questions, which are sent to
///      `/api/parts/scan/question` along with the same image.
class ScanPartChatScreen extends StatefulWidget {
  const ScanPartChatScreen({super.key});

  @override
  State<ScanPartChatScreen> createState() => _ScanPartChatScreenState();
}

class _ScanPartChatScreenState extends State<ScanPartChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final ApiService _api = ApiService();

  /// The captured image file.
  File? _imageFile;

  /// Base64-encoded image data persisted for follow-up questions.
  String? _imageBase64;

  /// MIME type of the captured image.
  String? _imageMimeType;

  /// Chat messages (local-only, not persisted).
  final List<AiChatMessage> _messages = [];

  /// Whether the AI is currently generating a response.
  bool _isTyping = false;

  // --------------------------------------------------------------------------
  // Lifecycle
  // --------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Show the image source dialog after the first frame.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showImageSourceDialog(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Image capture
  // --------------------------------------------------------------------------

  Future<void> _showImageSourceDialog() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXLarge),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.zinc300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Choose an image source',
                style: AppTypography.h5.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMedium,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.electricBlue,
                  ),
                ),
                title: Text(
                  'Camera',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Take a photo of the car part',
                  style: AppTypography.bodySmall,
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              const SizedBox(height: AppSpacing.xs),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMedium,
                    ),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.electricBlue,
                  ),
                ),
                title: Text(
                  'Gallery',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Choose an existing photo',
                  style: AppTypography.bodySmall,
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );

    if (source == null) return; // user dismissed
    await _pickImage(source);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (xFile == null) return; // user cancelled

      final file = File(xFile.path);
      final bytes = await file.readAsBytes();
      final base64 = base64Encode(bytes);
      final ext = xFile.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';

      setState(() {
        _imageFile = file;
        _imageBase64 = base64;
        _imageMimeType = mime;
      });

      await _analyzeImage();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // --------------------------------------------------------------------------
  // AI communication
  // --------------------------------------------------------------------------

  Future<void> _analyzeImage() async {
    if (_imageBase64 == null || _imageMimeType == null) return;

    setState(() {
      _messages.add(AiChatMessage.user('Analyze this car part'));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _api.post(
        '/parts/scan',
        body: {'imageBase64': _imageBase64, 'mimeType': _imageMimeType},
      );

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['success'] == true && data['analysis'] != null) {
        setState(() {
          _messages.add(AiChatMessage.ai(data['analysis'] as String));
        });
      } else {
        setState(() {
          _messages.add(
            AiChatMessage.aiError(
              data['message'] as String? ?? 'Analysis failed',
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(AiChatMessage.aiError(e.toString()));
      });
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  Future<void> _sendFollowUp() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _imageBase64 == null) return;

    _controller.clear();
    setState(() {
      _messages.add(AiChatMessage.user(text));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _api.post(
        '/parts/scan/question',
        body: {
          'imageBase64': _imageBase64,
          'mimeType': _imageMimeType,
          'question': text,
        },
      );

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['success'] == true && data['answer'] != null) {
        setState(() {
          _messages.add(AiChatMessage.ai(data['answer'] as String));
        });
      } else {
        setState(() {
          _messages.add(
            AiChatMessage.aiError(
              data['message'] as String? ?? 'Failed to answer question',
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(AiChatMessage.aiError(e.toString()));
      });
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

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

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
            // Image preview strip
            if (_imageFile != null) _buildImageStrip(),
            // Messages or empty state
            Expanded(
              child: _messages.isEmpty && !_isTyping
                  ? _buildEmptyState()
                  : _buildMessageList(),
            ),
            // Input area (only after image is captured)
            if (_imageFile != null) _buildInputArea(),
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
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Part Scanner',
                style: AppTypography.h5.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _isTyping
                    ? 'Analyzing…'
                    : _imageFile != null
                    ? 'Image captured'
                    : 'Waiting for image',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Re-scan button
        IconButton(
          icon: const Icon(Icons.add_a_photo_outlined, color: Colors.white),
          tooltip: 'Scan another part',
          onPressed: _showImageSourceDialog,
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Image strip
  // --------------------------------------------------------------------------

  Widget _buildImageStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            child: Image.file(
              _imageFile!,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scanned Part',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Ask follow-up questions about this part',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.electricBlue,
            ),
            tooltip: 'Change image',
            onPressed: _showImageSourceDialog,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Empty state
  // --------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 40,
                color: AppColors.electricBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Scan a Car Part',
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Take a photo or choose an image of any car part to get '
              'an AI-powered analysis.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Capture Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Message list
  // --------------------------------------------------------------------------

  Widget _buildMessageList() {
    final totalCount = _messages.length + (_isTyping ? 1 : 0);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        return _buildBubble(_messages[index]);
      },
    );
  }

  // --------------------------------------------------------------------------
  // Chat bubbles (mirrored from old AiAssistantScreen)
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
                hintText: 'Ask about this part…',
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
              onSubmitted: (_) => _sendFollowUp(),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Material(
            color: AppColors.electricBlue,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            child: InkWell(
              onTap: _isTyping ? null : _sendFollowUp,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: _isTyping
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
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Bouncing dots typing indicator
// =============================================================================

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
