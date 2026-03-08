import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _titleController = TextEditingController(text: user?.title ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<AuthController>().updateProfile(
          name: _nameController.text,
          title: _titleController.text,
          location: _locationController.text,
          phone: _phoneController.text,
          bio: _bioController.text,
        );
    AppSnackbar.show('Profil mis à jour.', success: true);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier mon profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Field(label: 'Nom complet', controller: _nameController),
            const SizedBox(height: 16),
            _Field(label: 'Intitulé de poste', controller: _titleController),
            const SizedBox(height: 16),
            _Field(label: 'Localisation', controller: _locationController),
            const SizedBox(height: 16),
            _Field(
              label: 'Téléphone',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Présentation',
              controller: _bioController,
              maxLines: 5,
              hint:
                  'Présentez-vous en quelques phrases, vos domaines d’expertise et réussites clés.',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Enregistrer les modifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
