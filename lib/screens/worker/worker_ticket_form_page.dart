import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/models/ticket.dart';
import 'package:laporpak_fp/screens/maintenance/ticket_copy_with.dart';
import 'package:laporpak_fp/screens/worker/worker_services.dart';

class WorkerTicketFormPage extends StatefulWidget {
  final AppUser user;
  final Ticket? existing;

  const WorkerTicketFormPage({super.key, required this.user, this.existing});

  @override
  State<WorkerTicketFormPage> createState() => _WorkerTicketFormPageState();
}

class _WorkerTicketFormPageState extends State<WorkerTicketFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;

  late HazardCategory _category;
  late UrgencyLevel _urgency;
  XFile? _pickedFile;
  String? _existingPhotoUrl;
  bool _submitting = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _locationController = TextEditingController(text: e?.location ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _category = e?.category ?? HazardCategory.structural;
    _urgency = e?.urgency ?? UrgencyLevel.medium;
    _existingPhotoUrl = (e?.photoUrl.isNotEmpty == true) ? e!.photoUrl : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Report' : 'New Hazard Report'),
        elevation: 0.5,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Title'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Leaking pipe in corridor B',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              _sectionLabel('Location'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'e.g. 2nd floor, Room 204',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16),
              _sectionLabel('Details'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe the hazard in detail...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter details' : null,
              ),
              const SizedBox(height: 16),
              _sectionLabel('Category'),
              const SizedBox(height: 6),
              _CategoryDropdown(
                value: _category,
                onChanged: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: 16),
              _sectionLabel('Urgency'),
              const SizedBox(height: 6),
              _UrgencyDropdown(
                value: _urgency,
                onChanged: (v) => setState(() => _urgency = v),
              ),
              const SizedBox(height: 16),
              _sectionLabel('Photo (optional)'),
              const SizedBox(height: 6),
              _photoSection(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_submitting
                      ? 'Saving...'
                      : _isEdit
                          ? 'Save Changes'
                          : 'Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget _photoSection() {
    if (_pickedFile != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, size: 56, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _pickedFile!.name,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: const Text('Change photo'),
          ),
        ],
      );
    }

    if (_existingPhotoUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _existingPhotoUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    ),
              errorBuilder: (_, _, _) => const SizedBox(
                height: 100,
                child: Center(
                  child: Icon(Icons.broken_image_outlined, color: Colors.grey),
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: const Text('Replace photo'),
          ),
        ],
      );
    }

    return OutlinedButton.icon(
      onPressed: _pickImage,
      icon: const Icon(Icons.add_a_photo_outlined),
      label: const Text('Add photo'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final file = await picker.pickImage(source: source, imageQuality: 80);
    if (file != null) {
      setState(() {
        _pickedFile = file;
        _existingPhotoUrl = null;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final services = WorkerServices.instance;
      String photoUrl = _existingPhotoUrl ?? '';

      if (_pickedFile != null) {
        photoUrl = await services.storage.uploadPhoto(filePath: _pickedFile!.path);
      }

      final now = DateTime.now();

      if (_isEdit) {
        final updated = widget.existing!.copyWith(
          title: _titleController.text.trim(),
          location: _locationController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
          urgency: _urgency,
          photoUrl: photoUrl,
          updatedAt: now,
        );
        await services.repo.updateTicket(updated);
      } else {
        final ticket = Ticket(
          id: services.newTicketId(),
          title: _titleController.text.trim(),
          location: _locationController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
          urgency: _urgency,
          status: TicketStatus.open,
          department: widget.user.department,
          workerId: widget.user.workerId,
          workerName: widget.user.name,
          workerDepartment: widget.user.department,
          assigneeId: null,
          supervisorId: null,
          deadline: null,
          createdAt: now,
          updatedAt: now,
          resolutionReport: null,
          photoUrl: photoUrl,
        );
        await services.repo.createTicket(ticket);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit
                ? 'Report updated successfully.'
                : 'Hazard report submitted.'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _CategoryDropdown extends StatelessWidget {
  final HazardCategory value;
  final ValueChanged<HazardCategory> onChanged;

  const _CategoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<HazardCategory>(
      initialValue: value,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: HazardCategory.values.map((c) {
        return DropdownMenuItem(value: c, child: Text(_label(c)));
      }).toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }

  String _label(HazardCategory c) {
    switch (c) {
      case HazardCategory.electrical: return 'Electrical';
      case HazardCategory.chemical: return 'Chemical';
      case HazardCategory.structural: return 'Structural';
      case HazardCategory.janitorial: return 'Janitorial';
    }
  }
}

class _UrgencyDropdown extends StatelessWidget {
  final UrgencyLevel value;
  final ValueChanged<UrgencyLevel> onChanged;

  const _UrgencyDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<UrgencyLevel>(
      initialValue: value,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: UrgencyLevel.values.map((u) {
        return DropdownMenuItem(value: u, child: Text(_label(u)));
      }).toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }

  String _label(UrgencyLevel u) {
    switch (u) {
      case UrgencyLevel.low: return 'Low';
      case UrgencyLevel.medium: return 'Medium';
      case UrgencyLevel.high: return 'High';
      case UrgencyLevel.critical: return 'Critical';
    }
  }
}
