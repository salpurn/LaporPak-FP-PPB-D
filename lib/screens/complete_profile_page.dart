import 'package:flutter/material.dart';
import '../core/constants/enums.dart';
import '../core/models/app_user.dart';
import '../services/auth_service.dart';

class CompleteProfilePage extends StatefulWidget {
  final AppUser user;
  const CompleteProfilePage({super.key, required this.user});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  late final TextEditingController _idController;
  late final TextEditingController _nameController;
  late final TextEditingController _departmentController;
  late UserRole _selectedRole;
  final _service = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.user.workerId);
    _nameController = TextEditingController(text: widget.user.name);
    _departmentController = TextEditingController(text: widget.user.department);
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final id = _idController.text.trim();
    final name = _nameController.text.trim();
    final dept = _departmentController.text.trim();

    if (id.isEmpty || name.isEmpty || dept.isEmpty) {
      setState(() => _error = 'Semua kolom wajib diisi.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _service.updateProfile(
        uid: widget.user.uid,
        workerId: id,
        name: name,
        role: _selectedRole,
        department: dept,
      );

      if (!mounted) return;

      final String route;
      switch (_selectedRole) {
        case UserRole.floorWorker:
          route = '/worker-dashboard';
        case UserRole.supervisor:
          route = '/supervisor-dashboard';
        case UserRole.maintenance:
          route = '/maintenance-dashboard';
      }

      Navigator.pushReplacementNamed(context, route);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lengkapi Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profil kamu belum lengkap. Isi data berikut untuk melanjutkan.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Simpan & Lanjutkan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
