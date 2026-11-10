import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../viewmodels/community_viewmodel.dart';

class CreateEventModal extends StatefulWidget {
  const CreateEventModal({super.key});

  @override
  State<CreateEventModal> createState() => _CreateEventModalState();
}

class _CreateEventModalState extends State<CreateEventModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _organizerController = TextEditingController(
    text: 'OpenPro Engineering Hub',
  );
  final _dateController = TextEditingController(
    text: 'Wednesday, Dec 2 • 11:00 AM PST',
  );
  final _locationController = TextEditingController(
    text: 'Virtual Studio Broadcast',
  );
  final _speakersController = TextEditingController(
    text: 'Safeer Hussain, Elena Rostova',
  );
  bool _isVirtual = true;
  bool _isPublishing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _organizerController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _speakersController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPublishing = true);
    final vm = context.read<CommunityViewModel>();

    final speakers = _speakersController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    await vm.createEvent(
      title: _titleController.text.trim(),
      organizer: _organizerController.text.trim(),
      dateDescription: _dateController.text.trim(),
      locationOrLink: _locationController.text.trim(),
      isVirtual: _isVirtual,
      speakers: speakers,
      tags: ['#Architecture', '#Webinar', '#Executive'],
    );

    if (mounted) {
      setState(() => _isPublishing = false);
      Navigator.pop(context);
      AppFeedback.showSuccess(
        context,
        'Executive Event created and published.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Host Executive Tech Event',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Event Title *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Flutter 3.47 Impeller Benchmark Roundtable',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Event title is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Organizer Organization *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _organizerController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Organizer name is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Date & Time *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _dateController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Date description is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Location / Stream URL *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Location or link is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Virtual Broadcast Event',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  value: _isVirtual,
                  onChanged: (val) => setState(() => _isVirtual = val),
                ),
                const SizedBox(height: 6),
                Text(
                  'Keynote Speakers (comma separated)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _speakersController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isPublishing ? null : _submit,
                    child: _isPublishing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Text(
                            'Publish & Host Event',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
