import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../viewmodels/profile_viewmodel.dart';

class AddExperienceModal extends StatefulWidget {
  const AddExperienceModal({super.key});

  @override
  State<AddExperienceModal> createState() => _AddExperienceModalState();
}

class _AddExperienceModalState extends State<AddExperienceModal> {
  final _formKey = GlobalKey<FormState>();
  final _roleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _startDateController = TextEditingController(text: '2024');
  final _endDateController = TextEditingController(text: 'Present');
  final _descriptionController = TextEditingController();
  bool _isCurrent = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _roleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final vm = context.read<ProfileViewModel>();

    await vm.addExperience(
      role: _roleController.text.trim(),
      company: _companyController.text.trim(),
      location: _locationController.text.trim(),
      startDate: _startDateController.text.trim(),
      endDate: _isCurrent ? 'Present' : _endDateController.text.trim(),
      isCurrent: _isCurrent,
      description: _descriptionController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      AppFeedback.showSuccess(
        context,
        'Role added to your executive timeline.',
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
                  'Add Professional Experience',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Role Title *',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _roleController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Lead Platform Engineer',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Role title is required'
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Company / Organization *',
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
                  decoration: const InputDecoration(
                    hintText: 'e.g. NextGen Systems',
                  ),
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
                  decoration: const InputDecoration(
                    hintText: 'e.g. San Francisco, CA (Remote)',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Location is required'
                      : null,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'I currently work in this role',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  value: _isCurrent,
                  onChanged: (val) => setState(() => _isCurrent = val),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Year *',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _startDateController,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    if (!_isCurrent) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Year *',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _endDateController,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Key Architectural Achievements *',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    hintText: 'Engineered high-throughput event buses, scaled to 3M MAU...',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Description is required'
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
                            'Add to Profile',
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
