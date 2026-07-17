class AppConstants {
  // GitHub Backend Configuration
  static const String githubUsername = 'msitarzewski'; // Target repo owner (or placeholder)
  static const String githubRepoName = 'agency-agents'; // Target repository name
  static const String githubBranch = 'main';

  // Base URL for fetching raw files from GitHub CDN
  static const String githubRawBaseUrl = 'https://raw.githubusercontent.com/$githubUsername/$githubRepoName/$githubBranch';
  
  // Alternatively using jsDelivr CDN for better caching and bypassing API rate limits
  static const String jsDelivrBaseUrl = 'https://cdn.jsdelivr.net/gh/$githubUsername/$githubRepoName@$githubBranch';

  // Endpoints/Paths on GitHub Repository
  static const String manifestPath = '/config/manifest.json';
  static const String appConfigPath = '/config/app_config.json';
  static const String questionsDir = '/questions';
  static const String materialsDir = '/materials';

  // Local Storage (Hive Box Names)
  static const String profileBox = 'profile_box';
  static const String progressBox = 'progress_box';
  static const String settingsBox = 'settings_box';
  static const String questionsBox = 'questions_box';
  static const String downloadsBox = 'downloads_box';

  // Hive Keys
  static const String profileKey = 'user_profile';
  static const String settingsKey = 'user_settings';

  // Gameplay Settings
  static const int dailyGoalQuestions = 10;
  static const int coinsPerCorrectAnswer = 1;
  static const int coinsForHint = 5;
  static const int coinsForStreakFreeze = 15;
  static const int referralBonusCoins = 20;

  // App Metadata
  static const String appVersion = '1.0.0';
  static const String appName = 'GST CBT';
  static const String poweredBy = 'Powered by Siyayya.com';
  static const String contactEmail = 'support@siyayya.com';
  static const String webUrl = 'https://siyayya.com';
}
