import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_chat_message.dart';
import '../models/chat_session.dart';
import '../services/ai_chat_service.dart';
import '../services/connectivity_service.dart';

/// State management for the AI Assistant chat.
///
/// Supports multiple chat sessions with local persistence.
/// Each session has its own message history. Users can create new chats,
/// switch between sessions, and delete old conversations.
class AiChatProvider extends ChangeNotifier {
  final AiChatService _chatService = AiChatService();
  final ConnectivityService _connectivity = ConnectivityService();

  /// All chat sessions, newest first.
  List<ChatSession> _sessions = [];

  /// The currently active session ID.
  String? _activeSessionId;

  VehicleContext? _vehicleContext;
  bool _isTyping = false;

  static const String _storageKey = 'ai_chat_sessions_v2';

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// All sessions, newest first.
  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  /// The currently active session (or null if none).
  ChatSession? get activeSession {
    if (_activeSessionId == null) return null;
    try {
      return _sessions.firstWhere((s) => s.id == _activeSessionId);
    } catch (_) {
      return null;
    }
  }

  /// Messages in the active session.
  List<AiChatMessage> get messages => activeSession?.messages ?? [];

  /// Whether the AI is currently generating a response.
  bool get isTyping => _isTyping;

  /// The current vehicle context (if any).
  VehicleContext? get vehicleContext => _vehicleContext;

  /// Whether the active session has any messages.
  bool get hasMessages => activeSession?.hasMessages ?? false;

  /// Whether there are any sessions at all.
  bool get hasSessions => _sessions.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Session management
  // ---------------------------------------------------------------------------

  /// Create a new chat session and make it active.
  void createNewChat() {
    final session = ChatSession.create();
    _sessions.insert(0, session);
    _activeSessionId = session.id;
    notifyListeners();
    _saveSessions();
  }

  /// Switch to an existing session by ID.
  void switchToSession(String sessionId) {
    if (_sessions.any((s) => s.id == sessionId)) {
      _activeSessionId = sessionId;
      notifyListeners();
    }
  }

  /// Delete a session by ID.
  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_activeSessionId == sessionId) {
      _activeSessionId = _sessions.isNotEmpty ? _sessions.first.id : null;
    }
    notifyListeners();
    _saveSessions();
  }

  // ---------------------------------------------------------------------------
  // Vehicle context
  // ---------------------------------------------------------------------------

  /// Set the vehicle context for subsequent messages.
  void setVehicleContext(VehicleContext? context) {
    _vehicleContext = context;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Send message
  // ---------------------------------------------------------------------------

  /// Send a user message and request an AI response.
  ///
  /// When offline, the user message is still added (and persisted) but
  /// the AI response is replaced with a friendly offline notice.
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Ensure we have an active session
    if (activeSession == null) {
      createNewChat();
    }

    final sessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (sessionIndex == -1) return;

    // Add user message
    final userMessage = AiChatMessage.user(content.trim());
    final updatedMessages = List<AiChatMessage>.from(
      _sessions[sessionIndex].messages,
    )..add(userMessage);

    // Update session with new message and derived title
    _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
      messages: updatedMessages,
      title: updatedMessages.length == 1
          ? _sessions[sessionIndex]
                .copyWith(messages: updatedMessages)
                .derivedTitle
          : _sessions[sessionIndex].title,
      updatedAt: DateTime.now(),
    );

    _isTyping = true;
    notifyListeners();

    // Check connectivity before hitting the network
    if (!_connectivity.isOnline) {
      final errorMsg = AiChatMessage.aiError(
        'You\'re currently offline. Your message has been saved and you can '
        'retry when connectivity returns.',
      );
      _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
        messages: List<AiChatMessage>.from(_sessions[sessionIndex].messages)
          ..add(errorMsg),
        updatedAt: DateTime.now(),
      );
      _isTyping = false;
      notifyListeners();
      _saveSessions();
      return;
    }

    try {
      final responseText = await _chatService.sendMessage(
        content.trim(),
        vehicleContext: _vehicleContext,
      );

      final aiMessage = AiChatMessage.ai(responseText);
      _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
        messages: List<AiChatMessage>.from(_sessions[sessionIndex].messages)
          ..add(aiMessage),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      final errorMessage = AiChatMessage.aiError(e.toString());
      _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
        messages: List<AiChatMessage>.from(_sessions[sessionIndex].messages)
          ..add(errorMessage),
        updatedAt: DateTime.now(),
      );
    } finally {
      _isTyping = false;
      notifyListeners();
      _saveSessions();
    }
  }

  /// Retry the last failed AI response.
  Future<void> retryLastMessage() async {
    if (activeSession == null) return;

    final sessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (sessionIndex == -1) return;

    final msgs = List<AiChatMessage>.from(_sessions[sessionIndex].messages);

    // Find the last user message
    AiChatMessage? lastUserMsg;
    for (int i = msgs.length - 1; i >= 0; i--) {
      if (msgs[i].isUser) {
        lastUserMsg = msgs[i];
        break;
      }
    }
    if (lastUserMsg == null) return;

    // Remove any trailing error messages
    while (msgs.isNotEmpty && msgs.last.isError) {
      msgs.removeLast();
    }

    _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
      messages: msgs,
      updatedAt: DateTime.now(),
    );
    _isTyping = true;
    notifyListeners();

    try {
      final responseText = await _chatService.sendMessage(
        lastUserMsg.content,
        vehicleContext: _vehicleContext,
      );
      _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
        messages: List<AiChatMessage>.from(_sessions[sessionIndex].messages)
          ..add(AiChatMessage.ai(responseText)),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
        messages: List<AiChatMessage>.from(_sessions[sessionIndex].messages)
          ..add(AiChatMessage.aiError(e.toString())),
        updatedAt: DateTime.now(),
      );
    } finally {
      _isTyping = false;
      notifyListeners();
      _saveSessions();
    }
  }

  // ---------------------------------------------------------------------------
  // Chat history
  // ---------------------------------------------------------------------------

  /// Clear all messages in the active session.
  void clearChat() {
    if (activeSession == null) return;

    final sessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (sessionIndex == -1) return;

    _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
      messages: [],
      title: 'New Chat',
      updatedAt: DateTime.now(),
    );
    _isTyping = false;
    notifyListeners();
    _saveSessions();
  }

  /// Load chat sessions from local storage.
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try new format first
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final data = json.decode(raw) as Map<String, dynamic>;
        final sessionsList = data['sessions'] as List;
        _sessions = sessionsList
            .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
            .toList();
        _activeSessionId = data['activeSessionId'] as String?;

        // Ensure active session exists
        if (_activeSessionId != null &&
            !_sessions.any((s) => s.id == _activeSessionId)) {
          _activeSessionId = _sessions.isNotEmpty ? _sessions.first.id : null;
        }

        notifyListeners();
        return;
      }

      // Migrate from old format (single chat history)
      final oldRaw = prefs.getString('ai_chat_history');
      if (oldRaw != null) {
        final list = json.decode(oldRaw) as List;
        final oldMessages = list
            .map((e) => AiChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();

        if (oldMessages.isNotEmpty) {
          final migratedSession = ChatSession(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Migrated Chat',
            createdAt: oldMessages.first.timestamp,
            updatedAt: oldMessages.last.timestamp,
            messages: oldMessages,
          );
          _sessions = [migratedSession];
          _activeSessionId = migratedSession.id;

          // Save in new format and remove old key
          await _saveSessions();
          await prefs.remove('ai_chat_history');
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load AI chat history: $e');
    }
  }

  /// Export the full chat transcript as a single String.
  String exportTranscript() {
    final session = activeSession;
    if (session == null) return '';

    final buffer = StringBuffer();
    buffer.writeln('=== Moto Lens — AI Chat Transcript ===');
    buffer.writeln('Session: ${session.title}');
    if (_vehicleContext != null && !_vehicleContext!.isEmpty) {
      buffer.writeln('Vehicle: ${_vehicleContext!.displayLabel}');
    }
    buffer.writeln('');

    for (final msg in session.messages) {
      final label = msg.isUser ? 'You' : 'AI';
      final time = _formatTime(msg.timestamp);
      buffer.writeln('[$time] $label:');
      buffer.writeln(msg.content);
      buffer.writeln('');
    }

    return buffer.toString();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'sessions': _sessions.map((s) => s.toJson()).toList(),
        'activeSessionId': _activeSessionId,
      };
      await prefs.setString(_storageKey, json.encode(data));
    } catch (e) {
      debugPrint('Failed to save AI chat sessions: $e');
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
