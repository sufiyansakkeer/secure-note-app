class StorageKeys {
  static const String pinKey = 'secure_note_app_pin';
  static const String isFirstLaunch = 'is_first_launch';
  static const String themeMode = 'theme_mode';
}

class DatabaseConstants {
  static const String databaseName = 'secure_note_app.db';
  static const int databaseVersion = 1;
  
  // Notes table
  static const String notesTable = 'notes';
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnContent = 'content';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
}
