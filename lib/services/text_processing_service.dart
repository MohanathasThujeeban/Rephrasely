import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/text_models.dart';
import '../constants/app_config.dart';
import 'connectivity_service.dart';

class TextProcessingService {
  static const Duration timeoutDuration = Duration(seconds: 30);
  final ConnectivityService _connectivityService = ConnectivityService();
  
  String get baseUrl => ApiConfig.baseUrl;

  Future<TextResponse> summarizeText(TextRequest request) async {
    return _processText('/api/summarize', request);
  }

  Future<TextResponse> paraphraseText(TextRequest request) async {
    return _processText('/api/paraphrase', request);
  }

  Future<TextResponse> _processText(String endpoint, TextRequest request) async {
    try {
      // Check connectivity first
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        return const TextResponse(
          success: false,
          error: 'No internet connection. Please check your network and try again.',
        );
      }

      final url = Uri.parse('$baseUrl$endpoint');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return TextResponse.fromJson(responseData);
      } else {
        return TextResponse(
          success: false,
          error: responseData['error'] ?? 'Unknown error occurred',
        );
      }
    } on SocketException {
      return const TextResponse(
        success: false,
        error: 'No internet connection. Please check your network.',
      );
    } on HttpException {
      return const TextResponse(
        success: false,
        error: 'Server error. Please try again later.',
      );
    } on FormatException {
      return const TextResponse(
        success: false,
        error: 'Invalid response format from server.',
      );
    } catch (e) {
      return TextResponse(
        success: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Health check to verify backend connection
  Future<bool> checkBackendHealth() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}