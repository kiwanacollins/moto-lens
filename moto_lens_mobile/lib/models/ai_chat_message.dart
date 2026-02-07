/// AI Chat Message model for the AI Assistant feature.
///
/// Represents a single message in the AI chat conversation,
/// with support for both user and AI messages, status tracking,
/// and local persistence via JSON serialization.
library;

/// The sender of a chat message.
enum MessageSender { user, ai }

/// Delivery / generation status of a chat message.
enum MessageStatus { sending, delivered, error }

/// A single chat message in the AI Assistant conversation.
class AiChatMessage {
  final String id;
  final MessageSender sender;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final String? errorMessage;

  const AiChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.status = MessageStatus.delivered,
    this.errorMessage,
  });

  /// Whether this message was sent by the user.
  bool get isUser => sender == MessageSender.user;

  /// Whether this message was sent by the AI.
  bool get isAi => sender == MessageSender.ai;

  /// Whether the message is still being generated / sent.
  bool get isSending => status == MessageStatus.sending;

  /// Whether the message encountered an error.
  bool get isError => status == MessageStatus.error;

  // ---------------------------------------------------------------------------
  // Factories
  // ---------------------------------------------------------------------------

  /// Create a new user message.
  factory AiChatMessage.user(String content) {
    return AiChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.user,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
    );
  }

  /// Create a placeholder AI message while waiting for a response.
  factory AiChatMessage.aiLoading() {
    return AiChatMessage(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.ai,
      content: '',
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
  }

  /// Create a delivered AI response message.
  factory AiChatMessage.ai(String content) {
    return AiChatMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.ai,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
    );
  }

  /// Create an AI error message.
  factory AiChatMessage.aiError(String errorMessage) {
    return AiChatMessage(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.ai,
      content: 'Sorry, I couldn\'t process your request. Please try again.',
      timestamp: DateTime.now(),
      status: MessageStatus.error,
      errorMessage: errorMessage,
    );
  }

  // ---------------------------------------------------------------------------
  // JSON serialization
  // ---------------------------------------------------------------------------

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    return AiChatMessage(
      id: json['id'] as String,
      sender: json['sender'] == 'user' ? MessageSender.user : MessageSender.ai,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: _statusFromString(json['status'] as String? ?? 'delivered'),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender == MessageSender.user ? 'user' : 'ai',
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }

  static MessageStatus _statusFromString(String value) {
    switch (value) {
      case 'sending':
        return MessageStatus.sending;
      case 'error':
        return MessageStatus.error;
      default:
        return MessageStatus.delivered;
    }
  }

  // ---------------------------------------------------------------------------
  // Immutable updates
  // ---------------------------------------------------------------------------

  AiChatMessage copyWith({
    String? id,
    MessageSender? sender,
    String? content,
    DateTime? timestamp,
    MessageStatus? status,
    String? errorMessage,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
