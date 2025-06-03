class User {
  final String username;
  final String? accessToken;
  final String? refreshToken;
  final String? role;
  final bool? isStaff;
  final bool? isWardExecutive;

  User({
    required this.username,
    this.accessToken,
    this.refreshToken,
    this.role,
    this.isStaff,
    this.isWardExecutive,
  });

  factory User.fromLoginJson(Map<String, dynamic> json) {
    final user = json['user'];
    return User(
      username: user['username'],
      accessToken: user['accessToken'],
      refreshToken: user['refreshToken'],
      isStaff: user['isStaff'],
      isWardExecutive: user['isWardExecutive'],
    );
  }

  factory User.fromRegisterJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      role: json['role'],
      isStaff: json['isStaff'],
      isWardExecutive: json['isSuperuser'],
    );
  }

}
