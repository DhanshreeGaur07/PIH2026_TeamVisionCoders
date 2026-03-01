import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url =>
      dotenv.env['SUPABASE_URL'] ?? 'https://yteuzaqffybbdfscyhbc.supabase.co';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';
  static String get webApiBaseUrl =>
      dotenv.env['WEB_API_BASE_URL'] ?? 'http://localhost:8080';
}
