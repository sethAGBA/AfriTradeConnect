import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/config.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial());

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final response = await http.post(
        Uri.parse('${Config.authUrl}/login'),
        headers: Config.defaultHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final payload = Jwt.parseJwt(token);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('userId', payload['userId']);
        await prefs.setString('userName', data['user']['name']);
        await prefs.setString('userEmail', data['user']['email']);

        state = AuthState.authenticated(token);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AuthState.initial();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

sealed class AuthState {
  const factory AuthState.initial() = InitialAuthState;
  const factory AuthState.loading() = LoadingAuthState;
  const factory AuthState.authenticated(String token) = AuthenticatedAuthState;
  const factory AuthState.error(String message) = ErrorAuthState;
}

class InitialAuthState implements AuthState {
  const InitialAuthState();
}

class LoadingAuthState implements AuthState {
  const LoadingAuthState();
}

class AuthenticatedAuthState implements AuthState {
  final String token;
  const AuthenticatedAuthState(this.token);
}

class ErrorAuthState implements AuthState {
  final String message;
  const ErrorAuthState(this.message);
}