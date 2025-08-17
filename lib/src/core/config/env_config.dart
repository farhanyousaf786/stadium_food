class EnvConfig {
  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );
  
  static bool get hasOpenAiKey => openAiApiKey.isNotEmpty;
}
