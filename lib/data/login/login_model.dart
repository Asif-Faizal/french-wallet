class LoginRequest {
  final String mobile;
  final String password;

  LoginRequest({required this.mobile, required this.password});

  Map<String, dynamic> toJson() => {
        'mobile': mobile,
        'password': password,
      };
}

class LoginResponse {
  final String status;
  final String message;

  LoginResponse({required this.status, required this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      message: json['message'],
    );
  }
}
