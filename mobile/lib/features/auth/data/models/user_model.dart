import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.profilePictureUrl,
    required super.timezone,
    required super.country,
    required super.language,
    required super.darkModePreference,
    super.bio,
    required super.level,
    required super.xp,
    required super.currentStreak,
    required super.bestStreak,
    required super.memberSince,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      timezone: json['timezone'] as String,
      country: json['country'] as String,
      language: json['language'] as String,
      darkModePreference: json['darkModePreference'] as bool? ?? true,
      bio: json['bio'] as String?,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      memberSince: DateTime.parse(json['memberSince'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'profilePictureUrl': profilePictureUrl,
        'timezone': timezone,
        'country': country,
        'language': language,
        'darkModePreference': darkModePreference,
        'bio': bio,
        'level': level,
        'xp': xp,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'memberSince': memberSince.toIso8601String(),
      };
}
