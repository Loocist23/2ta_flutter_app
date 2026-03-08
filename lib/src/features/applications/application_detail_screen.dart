import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/user.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';

class ApplicationDetailScreen extends StatefulWidget {
  const ApplicationDetailScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  late ApplicationStatus _status;
  late TextEditingController _nextStepController;
  final _noteController = TextEditingController();

  UserApplication? _findApplication(AppUser? user) {
    if (user == null) {
      return null;
    }
    for (final application in user.applications) {
      if (application.id == widget.applicationId) {
        return application;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _nextStepController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();
    final application = _findApplication(auth.user);
    _status = application?.status ?? ApplicationStatus.sent;
    _nextStepController =
        TextEditingController(text: application?.nextStep ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final application = _findApplication(auth.user);

    if (application == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Candidature introuvable'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Suivi de candidature')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.work, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          application.company,
                          style: const TextStyle(color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Statut actuel',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ApplicationStatus>(
              initialValue: _status,
              items: ApplicationStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nextStepController,
              decoration: const InputDecoration(
                labelText: 'Prochaine étape',
                hintText: 'Décrivez la prochaine action à mener',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Ajouter une note',
                hintText: 'Ajoutez vos retours d’entretien, ressentis, etc.',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            if (application.notes.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historique des notes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...application.notes.map((note) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.edit_note,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  note,
                                  style:
                                      const TextStyle(color: AppColors.grayDark),
                                ),
                              )
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  auth.updateApplication(
                    application.id,
                    status: _status,
                    nextStep: _nextStepController.text.trim().isEmpty
                        ? null
                        : _nextStepController.text.trim(),
                  );
                  if (_noteController.text.trim().isNotEmpty) {
                    auth.addApplicationNote(application.id, _noteController.text.trim());
                    _noteController.clear();
                  }
                  AppSnackbar.show('Candidature mise à jour.', success: true);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
