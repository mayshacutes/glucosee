import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://bjagjnrmyuymlxcezufg.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJqYWdqbnJteXV5bWx4Y2V6dWZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNDMwMTAsImV4cCI6MjA5NTYxOTAxMH0.CxRWE4sCxTUAnexPFng91ZsmLOUhzcSiPiWTVFWWsBo';

  static Future<void> init() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}