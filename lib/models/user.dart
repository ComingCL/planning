class User {
  final String id;
  final String? phone;
  final String? wechatId;
  final String nickname;
  final String? avatar;
  final String? email;
  final DateTime createdAt;

  User({
    required this.id,
    this.phone,
    this.wechatId,
    required this.nickname,
    this.avatar,
    this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'wechat_id': wechatId,
        'nickname': nickname,
        'avatar': avatar,
        'email': email,
        'created_at': createdAt.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        phone: json['phone'] as String?,
        wechatId: json['wechat_id'] as String?,
        nickname: json['nickname'] as String,
        avatar: json['avatar'] as String?,
        email: json['email'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  User copyWith({
    String? id,
    String? phone,
    String? wechatId,
    String? nickname,
    String? avatar,
    String? email,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      wechatId: wechatId ?? this.wechatId,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
