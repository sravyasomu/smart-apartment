import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';
import 'admin_login_screen.dart';
import 'reg_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool passwordVisible = false;
  bool isLoading = false;

  final String apiUrl = 'http://127.0.0.1:3000/api/login';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // RESIDENT LOGIN
  Future<void> login() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');

      final dynamic decodedResponse = jsonDecode(response.body);

      if (decodedResponse is! Map<String, dynamic>) {
        throw const FormatException(
          'The server returned an unexpected response.',
        );
      }

      final Map<String, dynamic> responseData = decodedResponse;

      if (!mounted) return;

      if (response.statusCode == 200 &&
          responseData['success'] == true) {
        final dynamic userData = responseData['user'];

        if (userData is! Map) {
          throw const FormatException(
            'User information is missing from the server response.',
          );
        }

        final Map<String, dynamic> user =
            Map<String, dynamic>.from(userData);

        final dynamic rawId = user['id'];

        if (rawId == null) {
          throw const FormatException(
            'User ID is missing from the login response.',
          );
        }

        final int? userId = int.tryParse(rawId.toString());

        if (userId == null || userId <= 0) {
          throw const FormatException(
            'The user ID returned by the server is invalid.',
          );
        }

        final String userName = user['name']?.toString() ?? '';
        final String apartmentNumber =
            user['apartment_number']?.toString() ?? '';
        final String block = user['block']?.toString() ?? '';
        final String role =
            user['role']?.toString().toLowerCase() ?? 'resident';

        // Admin accounts must use the separate Admin Login screen.
        if (role == 'admin') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please use the Admin Login button to access the dashboard.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        if (role != 'resident') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your account does not have resident access.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, $userName!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Open the resident home screen.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (context) => HomeScreen(
              userId: userId,
              userName: userName,
              apartmentNumber: apartmentNumber,
              block: block,
            ),
          ),
        );
      } else {
        final String message =
            responseData['message']?.toString() ??
                'Login failed. Please try again.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on TimeoutException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The server took too long to respond.'),
          backgroundColor: Colors.red,
        ),
      );
    } on http.ClientException catch (e) {
      debugPrint('HTTP client error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not reach the backend. Check that the server is running.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 8),
        ),
      );
    } on FormatException catch (e) {
      debugPrint('Response format error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid server response: ${e.message}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
    } catch (e) {
      debugPrint('Login error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // OPEN RESIDENT REGISTRATION
  void openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const RegScreen(),
      ),
    );
  }

  // OPEN ADMIN LOGIN
  void openAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const AdminLoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // APP ICON
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // APP NAME
                  const Text(
                    'Smart Apartment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Login to continue',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // EMAIL FIELD
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: 'Email',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: 'Enter your registered email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // PASSWORD FIELD
                  TextField(
                    controller: passwordController,
                    obscureText: !passwordVisible,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) {
                      if (!isLoading) {
                        login();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // RESIDENT LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // RESIDENT REGISTRATION LINK
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      const Text(
                        "Don't have an account?",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : openRegister,
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Color(0xFF1976D2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Register an account before logging in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DIVIDER
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // ADMIN LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : openAdminLogin,
                      icon: const Icon(
                        Icons.admin_panel_settings_outlined,
                      ),
                      label: const Text(
                        'ADMIN LOGIN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2457C5),
                        side: const BorderSide(
                          color: Color(0xFF2457C5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'For apartment administrators only',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}