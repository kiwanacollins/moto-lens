import 'dart:convert';
import 'api_service.dart';

/// Vehicle context for grounding AI responses.
class VehicleContext {
  final String? make;
  final String? model;
  final String? year;
  final String? vin;

  const VehicleContext({this.make, this.model, this.year, this.vin});

  Map<String, dynamic> toJson() => {
    if (make != null) 'make': make,
    if (model != null) 'model': model,
    if (year != null) 'year': year,
    if (vin != null) 'vin': vin,
  };

  /// Human-readable label e.g. "2020 BMW 3 Series".
  String get displayLabel {
    final parts = <String>[];
    if (year != null) parts.add(year!);
    if (make != null) parts.add(make!);
    if (model != null) parts.add(model!);
    return parts.isEmpty ? 'Unknown vehicle' : parts.join(' ');
  }

  bool get isEmpty =>
      make == null && model == null && year == null && vin == null;
}

/// Service that communicates with the backend AI chat endpoint.
///
/// Singleton, wraps [ApiService] and exposes a simple [sendMessage] call.
class AiChatService {
  static final AiChatService _instance = AiChatService._internal();
  factory AiChatService() => _instance;
  AiChatService._internal();

  final ApiService _api = ApiService();

  /// Send a free-form message to the AI and get a text response.
  ///
  /// Optionally attach [vehicleContext] so the AI can tailor its answer.
  /// Returns the AI response text.
  Future<String> sendMessage(
    String message, {
    VehicleContext? vehicleContext,
  }) async {
    final body = <String, dynamic>{'message': message};

    if (vehicleContext != null && !vehicleContext.isEmpty) {
      body['vehicleContext'] = vehicleContext.toJson();
    }

    final response = await _api.post('/ai/chat', body: body);
    final data = json.decode(response.body) as Map<String, dynamic>;

    if (data['success'] == true && data['response'] != null) {
      return data['response'] as String;
    }

    throw AiChatException(data['message'] as String? ?? 'Unknown AI error');
  }
}

/// Exception thrown when the AI chat endpoint returns an error.
class AiChatException implements Exception {
  final String message;
  const AiChatException(this.message);

  @override
  String toString() => 'AiChatException: $message';
}
