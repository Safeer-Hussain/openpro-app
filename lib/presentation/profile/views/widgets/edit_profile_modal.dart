import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../../../domain/entities/user_profile_entity.dart';
import '../../viewmodels/profile_viewmodel.dart';

class EditProfileModal extends StatefulWidget {
  final UserProfileEntity profile;

  const EditProfileModal({super.key, required this.profile});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _titleController;
  late final TextEditingController _companyController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;
  late final TextEditingController _skillsController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _titleController = TextEditingController(text: widget.profile.title);
    _companyController = TextEditingController(text: widget.profile.company);
    _locationController = TextEditingController(text: widget.profile.location);
    _bioController = TextEditingController(text: widget.profile.bio);
    _skillsController = TextEditingController(
      text: widget.profile.skills.join(', '),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final vm = context.read<ProfileViewModel>();

    final skillsList = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    await vm.updateBioAndTitle(
      name: _nameController.text.trim(),
      title: _titleController.text.trim(),
      company: _companyController.text.trim(),
      location: _locationController.text.trim(),
      bio: _bioController.text.trim(),
      skills: skillsList,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      AppFeedback.showSuccess(
        context,
        'Executive Profile updated successfully.',
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
                  'Edit Executive Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Full Name *',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Professional Headline *',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Headline is required'
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Organization *',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _companyController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Company is required'
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Location *',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Location is required'
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Executive Bio *',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Bio is required'
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Verified Skills (Comma Separated) *',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _skillsController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Skills are required'
                      : null,
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
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Text(
                            'Save Changes',
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
