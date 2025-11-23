/// Supabase Configuration
/// Contains project URL and API keys for Supabase integration
class SupabaseConfig {
  // Project URL for flutter-messaging-video project
  // Located in: Supabase Dashboard > Project Settings > API
  static const String supabaseUrl = 'https://ojklyabjzjpudemyrqcy.supabase.co';

  // Anon/Public Key - Safe to use in client-side code
  // This key works with Row Level Security (RLS) policies
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9qa2x5YWJqempwdWRlbXlycWN5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MTgzMzIsImV4cCI6MjA3OTQ5NDMzMn0.Eh6dAiSeyTkQ63A8BIA-LIqs5Nyug6bnrCb3MEaM1Ds';

  // Note: Never commit real credentials to public repositories
  // For production, consider using environment variables or flutter_dotenv
}
