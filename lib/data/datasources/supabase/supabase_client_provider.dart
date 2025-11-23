import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Supabase Client Singleton
/// Provides access to the initialized Supabase client
class SupabaseClientProvider {
  static SupabaseClient? _instance;

  /// Get the Supabase client instance
  static SupabaseClient get instance {
    if (_instance == null) {
      throw StateError(
        'Supabase has not been initialized. Call SupabaseClientProvider.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _instance = Supabase.instance.client;
  }

  /// Check if Supabase is initialized
  static bool get isInitialized => _instance != null;
}
