class User {
  final int id;
  final String name;
  final String email;
  final String? username;
  final String? sessionId;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.sessionId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? json['login'] ?? '',
      username: json['username'] ?? json['login'],
      sessionId: json['session_token'] ?? json['session_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'session_id': sessionId,
    };
  }
}

class LoginRequest {
  final String username;  // Changed from email to username to match API
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String username;
  final String name;
  final String email;
  final String password;
  final String? confirmPassword;

  RegisterRequest({
    required this.username,
    required this.name,
    required this.email,
    required this.password,
    this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'username': username,
      'name': name,
      'email': email,
      'password': password,
    };
    
    if (confirmPassword != null) {
      data['confirm_password'] = confirmPassword!;
    }
    
    return data;
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
    );
  }
}
