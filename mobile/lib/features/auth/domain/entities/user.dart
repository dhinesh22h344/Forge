class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePictureUrl,
    required this.timezone,
    required this.country,
    required this.language,
    required this.darkModePreference,
    this.bio,
    required this.level,
    required this.xp,
    required this.currentStreak,
    required this.bestStreak,
    required this.memberSince,
  });

  final String id;
  final String username;
  final String email;
  final String? profilePictureUrl;
  final String timezone;
  final String country;
  final String language;
  final bool darkModePreference;
  final String? bio;
  final int level;
  final int xp;
  final int currentStreak;
  final int bestStreak;
  final DateTime memberSince;
}
