class AppConstants {
  static const String appName = 'My Vocabulary';
  static const String appSubtitle = 'IELTS Vocabulary Notebook';

  // Word Levels
  static const List<String> levels = [
    'Basic',
    'Advance',
  ];

  // Usage Categories
  static const List<String> usageCategories = [
    'Speaking',
    'Writing',
    'General',
  ];

  // Default IELTS Topics
  static const List<String> defaultTopics = [
    'Daily Objects',
    'Animals & Wildlife',
    'Fruits & Vegetables',
    'Food & Taste',
    'Nature & Forestry',
    'Weather & Climate',
    'Education',
    'Society',
    'Health',
    'Travel & Transport',
    'Places & Town',
    'Clothing & Accessories',
    'Shapes & Measurement',
    'Work & Career',
    'Technology',
    'Economy',
    'Environment',
    'Government',
    'Culture',
    'Crime',
    'Other',
  ];

  // Parts of Speech
  static const List<String> partsOfSpeech = [
    'Noun',
    'Verb',
    'Adjective',
    'Adverb',
    'Idiom',
    'Phrasal Verb',
    'Collocation',
    'Other',
  ];
}

enum VocabularySort {
  newest,
  alphabetical,
}
