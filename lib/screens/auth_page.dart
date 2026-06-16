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
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _service = AuthService();
  bool _isRegister = false;
  bool _loading = false;
  String? _error;
  UserRole _selectedRole = UserRole.floorWorker;

  Future<void> _submit() async {
    if (_isRegister) {
      if (_idController.text.trim().isEmpty ||
          _nameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _departmentController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {
        setState(() => _error = 'Semua kolom wajib diisi.');
        return;
      }
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isRegister) {
        await _service.register(
          workerId: _idController.text.trim(),
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole,
          department: _departmentController.text.trim(),
        );
        await _service.signOut();
        if (!mounted) return;
        setState(() {
          _isRegister = false;
          _error = null;
          _idController.clear();
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _departmentController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil dibuat. Silakan masuk.')),
        );
        return;
      }

      await _service.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

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
    _idController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'Daftar Akun' : 'Masuk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            if (_isRegister) ...[
              TextField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'ID Karyawan'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            if (_isRegister) ...[
              DropdownButtonFormField<UserRole>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(
                    value: UserRole.floorWorker,
                    child: Text('Floor Worker'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.supervisor,
                    child: Text('Supervisor'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.maintenance,
                    child: Text('Maintenance'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedRole = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Departemen'),
              ),
              const SizedBox(height: 12),
            ],
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
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isRegister ? 'Daftar' : 'Masuk'),
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
                _isRegister
                    ? 'Sudah punya akun? Masuk'
                    : 'Belum punya akun? Daftar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
