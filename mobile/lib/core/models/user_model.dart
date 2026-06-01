class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String provider;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.provider = 'email',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        provider: json['provider'] as String? ?? 'email',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'provider': provider,
      };

  UserModel copyWith({
    String? name,
    String? avatarUrl,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        provider: provider,
      );
}
