class LoginRequest {
  final String? phone;
  final String? code;
  final String? wechatCode;

  LoginRequest({
    this.phone,
    this.code,
    this.wechatCode,
  });

  LoginRequest.phone({
    required String phone,
    required String code,
  })  : phone = phone,
        code = code,
        wechatCode = null;

  LoginRequest.wechat({
    required String wechatCode,
  })  : phone = null,
        code = null,
        wechatCode = wechatCode;

  Map<String, dynamic> toJson() {
    if (wechatCode != null) {
      return {'code': wechatCode};
    }
    return {
      'phone': phone,
      'code': code,
    };
  }
}
