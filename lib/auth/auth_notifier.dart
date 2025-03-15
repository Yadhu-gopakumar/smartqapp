import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import 'dart:convert';
import '../main.dart';
import '../pages/loginpage.dart';
import '../provider/bottom_bar_provider.dart';
import '../provider/cartprovider.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;

  AuthState({required this.isAuthenticated, required this.isLoading});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isAuthenticated: false, isLoading: false));

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      state = AuthState(isAuthenticated: true, isLoading: false);
    }
  }

  Future<void> login(String email, String password, BuildContext context,
      WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    state = AuthState(isAuthenticated: false, isLoading: true); // Show loading

    final response = await http.post(
      Uri.parse('${baseUrl}login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      // Store the user's email
      await prefs.setString('userEmail', email);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          dismissDirection: DismissDirection.horizontal,
          padding: EdgeInsets.only(top: 20, bottom: 20),
          content: Center(
            child: Text(
              'Login success.',
              style: TextStyle(color: Colors.lightGreenAccent),
            ),
          ),
        ),
      );
      state = AuthState(isAuthenticated: true, isLoading: false);

      ref.read(bottomBarIndexProvider.notifier).state = 0;
      if (context.mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const BottomBar()));
      }
    } else {
      state = AuthState(isAuthenticated: true, isLoading: false);
      final errorMessage = jsonDecode(response.body)['error'] ?? 'Login failed';

      scaffoldMessenger.showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.horizontal,
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          content: Center(
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.orange,
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> register(
      String username, String password, BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Validate email format
    if (!EmailValidator.validate(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: Text(
              'Invalid email format',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
      return;
    }

    state = AuthState(isAuthenticated: false, isLoading: true); // Show loading

    final response = await http.post(
      Uri.parse('${baseUrl}signup'),
      body: jsonEncode({'email': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      state = AuthState(isAuthenticated: false, isLoading: false);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          dismissDirection: DismissDirection.horizontal,
          padding: EdgeInsets.only(top: 20, bottom: 20),
          content: Center(
            child: Text(
              'Registration successful. Please log in.',
              style: TextStyle(color: Colors.lightGreenAccent),
            ),
          ),
        ),
      );
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      }
    } else {
      state = AuthState(isAuthenticated: false, isLoading: false);
      final errorMessage =
          jsonDecode(response.body)['error'] ?? 'Registration failed';

      scaffoldMessenger.showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.horizontal,
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          content: Center(
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.orange,
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> logout(BuildContext context, WidgetRef ref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userEmail');


    // Clear cart properly using ref.read
    ref.read(cartProvider.notifier).clearCart();

    state = AuthState(isAuthenticated: false, isLoading: false);
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }
}
