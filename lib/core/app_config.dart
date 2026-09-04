class AppConfig {
  // Key is injected at build time via --dart-define=GEMINI_API_KEY=...
  // It is NOT stored in any file bundled inside the APK/AAB.
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
}
