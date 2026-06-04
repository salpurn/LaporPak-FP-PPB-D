import 'package:flutter/material.dart';
import '../core/constants/enums.dart';
import '../services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _service = AuthService();
  bool _isRegister = false;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isRegister) {
        await _service.register(_emailController.text.trim(), _passwordController.text.trim());
      } else {
        await _service.signIn(_emailController.text.trim(), _passwordController.text.trim());
      }

      if (!mounted) return;

      final currentUser = await _service.fetchCurrentUser();

      if (!mounted) return;

      final routeName = _routeForRole(currentUser?.role);
      if (routeName == null) {
        setState(() {
          _error = 'Role user tidak dikenali atau data profile belum lengkap.';
        });
        return;
      }

      Navigator.pushReplacementNamed(context, routeName);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String? _routeForRole(UserRole? role) {
    switch (role) {
      case UserRole.floorWorker:
        return '/worker-dashboard';
      case UserRole.supervisor:
        return '/supervisor-dashboard';
      case UserRole.maintenance:
        return '/maintenance-dashboard';
      case null:
        return null;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'Register' : 'Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isRegister ? 'Create account' : 'Sign in'),
              ),
            ),
            TextButton(
              onPressed: _loading
                  ? null
                  : () {
                      setState(() {
                        _isRegister = !_isRegister;
                        _error = null;
                      });
                    },
              child: Text(
                _isRegister ? 'Have an account? Sign in' : 'No account? Register',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
