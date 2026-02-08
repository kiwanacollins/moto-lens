import 'ai_chat_message.dart';

/// A single chat session (conversation thread).
///
/// Each session has a unique [id], a generated [title] derived from the
/// first user message, a [createdAt] timestamp, and its own list of
/// [messages]. Sessions are persisted locally via JSON serialization.
class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AiChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  /// Create a brand-new empty session.
  factory ChatSession.create() {
    final now = DateTime.now();
    return ChatSession(
      id: now.millisecondsSinceEpoch.toString(),
      title: 'New Chat',
      createdAt: now,
      updatedAt: now,
      messages: [],
    );
  }

  /// Whether this session has any messages.
  bool get hasMessages => messages.isNotEmpty;

  /// Number of messages in the session.
  int get messageCount => messages.length;

  /// A short preview of the conversation (last AI message, truncated).
  String get preview {
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].isAi && !messages[i].isError) {
        final text = messages[i].content.replaceAll(RegExp(r'\s+'), ' ');
        return text.length > 80 ? '${text.substring(0, 80)}…' : text;
      }
    }
    if (messages.isNotEmpty) {
      final text = messages.first.content.replaceAll(RegExp(r'\s+'), ' ');
      return text.length > 80 ? '${text.substring(0, 80)}…' : text;
    }
    return 'Empty conversation';
  }

  /// Derive a title from the first user message.
  String get derivedTitle {
    for (final msg in messages) {
      if (msg.isUser) {
        final text = msg.content.trim();
        return text.length > 40 ? '${text.substring(0, 40)}…' : text;
      }
    }
    return 'New Chat';
  }

  // ---------------------------------------------------------------------------
  // Immutable updates
  // ---------------------------------------------------------------------------

  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AiChatMessage>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  // ---------------------------------------------------------------------------
  // JSON serialization
  // ---------------------------------------------------------------------------

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'New Chat',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: (json['messages'] as List)
          .map((e) => AiChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatSession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
