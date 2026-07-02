import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads and validates Mapbox configuration from the environment.
class MapboxConfig {
  MapboxConfig._();

  static const String envKey = 'MAPBOX_ACCESS_TOKEN';
  static const String placeholderToken = 'pk.your_token_here';

  static String? get accessToken => dotenv.env[envKey]?.trim();

  static bool get isConfigured {
    final token = accessToken;
    if (token == null || token.isEmpty) {
      return false;
    }
    return token != placeholderToken && token.startsWith('pk.');
  }

  static String get statusLabel {
    if (isConfigured) {
      return 'Configured';
    }
    final token = accessToken;
    if (token == null || token.isEmpty) {
      return 'Missing token';
    }
    return 'Placeholder token';
  }
}
