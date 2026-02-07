import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_chat_message.dart';
import '../services/ai_chat_service.dart';

/// State management for the AI Assistant chat.
///
/// Holds the conversation, sends messages through [AiChatService],
/// and persists chat history to local storage.
class AiChatProvider extends ChangeNotifier {
  final AiChatService _chatService = AiChatService();

  List<AiChatMessage> _messages = [];
  VehicleContext? _vehicleContext;
  bool _isTyping = false;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// All messages in the current conversation, oldest first.
  List<AiChatMessage> get messages => List.unmodifiable(_messages);

  /// Whether the AI is currently generating a response.
  bool get isTyping => _isTyping;

  /// The current vehicle context (if any).
  VehicleContext? get vehicleContext => _vehicleContext;

  /// Whether the conversation has any messages.
  bool get hasMessages => _messages.isNotEmpty;

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
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = AiChatMessage.user(content.trim());
    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();

    try {
      final responseText = await _chatService.sendMessage(
        content.trim(),
        vehicleContext: _vehicleContext,
      );

      final aiMessage = AiChatMessage.ai(responseText);
      _messages.add(aiMessage);
    } catch (e) {
      final errorMessage = AiChatMessage.aiError(e.toString());
      _messages.add(errorMessage);
    } finally {
      _isTyping = false;
      notifyListeners();
      _saveHistory();
    }
  }

  /// Retry the last failed AI response.
  Future<void> retryLastMessage() async {
    // Find the last user message
    AiChatMessage? lastUserMsg;
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].isUser) {
        lastUserMsg = _messages[i];
        break;
      }
    }
    if (lastUserMsg == null) return;

    // Remove any trailing error messages
    while (_messages.isNotEmpty && _messages.last.isError) {
      _messages.removeLast();
    }
    notifyListeners();

    // Re-send
    _isTyping = true;
    notifyListeners();

    try {
      final responseText = await _chatService.sendMessage(
        lastUserMsg.content,
        vehicleContext: _vehicleContext,
      );
      _messages.add(AiChatMessage.ai(responseText));
    } catch (e) {
      _messages.add(AiChatMessage.aiError(e.toString()));
    } finally {
      _isTyping = false;
      notifyListeners();
      _saveHistory();
    }
  }

  // ---------------------------------------------------------------------------
  // Chat history
  // ---------------------------------------------------------------------------

  /// Clear all messages.
  void clearChat() {
    _messages = [];
    _isTyping = false;
    notifyListeners();
    _saveHistory();
  }

  /// Load chat history from local storage.
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('ai_chat_history');
      if (raw != null) {
        final list = json.decode(raw) as List;
        _messages = list
            .map((e) => AiChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load AI chat history: $e');
    }
  }

  /// Export the full chat transcript as a single String.
  String exportTranscript() {
    final buffer = StringBuffer();
    buffer.writeln('=== German Car Medic — AI Chat Transcript ===');
    if (_vehicleContext != null && !_vehicleContext!.isEmpty) {
      buffer.writeln('Vehicle: ${_vehicleContext!.displayLabel}');
    }
    buffer.writeln('');

    for (final msg in _messages) {
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

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_messages.map((m) => m.toJson()).toList());
      await prefs.setString('ai_chat_history', encoded);
    } catch (e) {
      debugPrint('Failed to save AI chat history: $e');
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
