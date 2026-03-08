import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../data/job_offers.dart';
import '../../models/user.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';

class NewApplicationScreen extends StatefulWidget {
  const NewApplicationScreen({super.key});

  @override
  State<NewApplicationScreen> createState() => _NewApplicationScreenState();
}

class _NewApplicationScreenState extends State<NewApplicationScreen> {
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _nextStepController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedJobId;
  ApplicationStatus _status = ApplicationStatus.sent;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _nextStepController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatAppliedOn() {
    final formatter = DateFormat('dd MMMM', 'fr_FR');
    return 'Candidature envoyée le ${formatter.format(DateTime.now())}';
  }

  void _submit(BuildContext context) {
    final title = _titleController.text.trim();
    final company = _companyController.text.trim();
    if (title.isEmpty || company.isEmpty) {
      AppSnackbar.show('Indiquez un poste et une entreprise.', success: false);
      return;
    }

    context.read<AuthController>().addApplication(
          jobId: _selectedJobId ?? title,
          company: company,
          title: title,
          status: _status,
          appliedOn: _formatAppliedOn(),
          nextStep:
              _nextStepController.text.trim().isEmpty ? null : _nextStepController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : [_notesController.text.trim()],
        );
    AppSnackbar.show('Candidature ajoutée à votre suivi.', success: true);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle candidature')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LabeledField(
              label: 'Poste',
              controller: _titleController,
              hintText: 'Titre du poste',
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Entreprise',
              controller: _companyController,
              hintText: 'Nom de l’entreprise',
            ),
            const SizedBox(height: 16),
            const Text(
              'Sélectionner une offre suggérée',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: jobOffers.take(5).map((job) {
                final isSelected = _selectedJobId == job.id;
                return ChoiceChip(
                  label: Text(job.title),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedJobId = job.id;
                      _titleController.text = job.title;
                      _companyController.text = job.company;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Statut',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: ApplicationStatus.values.map((status) {
                final isSelected = _status == status;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  title: Text(status.label),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : const Icon(Icons.radio_button_unchecked),
                  onTap: () => setState(() => _status = status),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Prochaine étape',
              controller: _nextStepController,
              hintText: 'Ex : Relancer dans une semaine…',
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Ajouter une note',
              controller: _notesController,
              hintText: 'Vos impressions, les points à relancer…',
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _submit(context),
                icon: const Icon(Icons.check),
                label: const Text('Enregistrer la candidature'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;

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
          decoration: InputDecoration(hintText: hintText),
        ),
      ],
    );
  }
}
