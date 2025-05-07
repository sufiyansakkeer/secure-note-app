class StorageKeys {
  static const String pinKey = 'secure_note_app_pin';
  static const String isFirstLaunch = 'is_first_launch';
  static const String themeMode = 'theme_mode';
}

class HiveConstants {
  // Box names
  static const String notesBox = 'notes_box';

  // Type IDs
  static const int noteTypeId = 0;

  // Field names (for consistency with previous implementation)
  static const String fieldId = 'id';
  static const String fieldTitle = 'title';
  static const String fieldContent = 'content';
  static const String fieldCreatedAt = 'created_at';
  static const String fieldUpdatedAt = 'updated_at';
}
