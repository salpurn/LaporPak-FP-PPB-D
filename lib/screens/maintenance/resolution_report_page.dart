import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/models/resolution_report.dart';
import 'package:laporpak_fp/core/models/ticket.dart';
import 'package:laporpak_fp/screens/maintenance/maintenance_services.dart';
import 'package:laporpak_fp/screens/maintenance/ticket_copy_with.dart';

class ResolutionReportPage extends StatefulWidget {
  final Ticket ticket;
  final AppUser user;
  final bool editMode;

  const ResolutionReportPage({
    super.key,
    required this.ticket,
    required this.user,
    required this.editMode,
  });

  @override
  State<ResolutionReportPage> createState() => _ResolutionReportPageState();
}

class _ResolutionReportPageState extends State<ResolutionReportPage> {
  late final TextEditingController _noteController;
  XFile? _pickedFile;
  String? _existingPhotoUrl;
  bool _submitting = false;

  bool get _canEdit =>
      widget.ticket.status == TicketStatus.pending ||
      widget.ticket.status == TicketStatus.rejected;

  @override
  void initState() {
    super.initState();
    final existing = widget.ticket.resolutionReport;
    _noteController = TextEditingController(
      text: widget.editMode ? (existing?.completionNote ?? '') : '',
    );
    _existingPhotoUrl = (existing?.photoUrl.isNotEmpty == true) ? existing!.photoUrl : null;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget.editMode && !_canEdit;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editMode ? 'Edit Report' : 'Submit Report'),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.ticket.status == TicketStatus.rejected)
              _rejectedBanner(),
            if (isReadOnly)
              _readOnlyBanner(),
            const Text(
              'Completion Note',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              enabled: !isReadOnly,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe what was done to fix this hazard...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Photo Evidence',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _photoSection(isReadOnly),
            const SizedBox(height: 32),
            if (!isReadOnly)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_submitting
                      ? 'Submitting...'
                      : widget.editMode
                          ? 'Save Changes'
                          : 'Submit Report'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _photoSection(bool isReadOnly) {
    if (_pickedFile != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, size: 64, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _pickedFile!.name,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (!isReadOnly)
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
              height: 200,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
              errorBuilder: (_, _, _) => const SizedBox(
                height: 100,
                child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
              ),
            ),
          ),
          if (!isReadOnly)
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.swap_horiz, size: 16),
              label: const Text('Replace photo'),
            ),
        ],
      );
    }

    return isReadOnly
        ? const Text(
            'No photo attached.',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          )
        : OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Add photo'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          );
  }

  Widget _rejectedBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD32F2F).withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFFD32F2F), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'This ticket was rejected by the supervisor. Please revise and resubmit.',
              style: TextStyle(color: Color(0xFFD32F2F), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.grey, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'This report is locked while the supervisor is reviewing.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
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
    final note = _noteController.text.trim();
    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a completion note.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final services = MaintenanceServices.instance;
      String photoUrl = _existingPhotoUrl ?? '';

      if (_pickedFile != null) {
        photoUrl = await services.storage.uploadPhoto(filePath: _pickedFile!.path);
      }

      final report = ResolutionReport(
        completionNote: note,
        photoUrl: photoUrl,
        submittedBy: widget.user.uid,
        submittedAt: DateTime.now(),
      );

      await services.repo.updateTicket(
        widget.ticket.copyWith(
          resolutionReport: report,
          status: TicketStatus.pending,
          updatedAt: DateTime.now(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editMode
                ? 'Report updated successfully.'
                : 'Report submitted — awaiting supervisor validation.'),
          ),
        );
        // Pop both this page and the detail page so the board reflects the new status
        Navigator.of(context)
          ..pop()
          ..pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
