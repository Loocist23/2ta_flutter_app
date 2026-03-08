import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../data/job_offers.dart';
import '../../models/job_offer.dart';
import '../../models/user.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';
import '../jobs/job_details_screen.dart';
import 'application_detail_screen.dart';
import 'new_application_screen.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  JobOffer? _jobFor(String jobId) {
    for (final job in jobOffers) {
      if (job.id == jobId) {
        return job;
      }
    }
    return null;
  }

  String _format(String prefix) {
    final date = DateTime.now();
    final formatter = DateFormat('dd MMMM', 'fr_FR');
    return '$prefix le ${formatter.format(date)}';
  }

  ApplicationStatus _nextStatus(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.sent:
        return ApplicationStatus.inReview;
      case ApplicationStatus.inReview:
        return ApplicationStatus.interview;
      case ApplicationStatus.interview:
        return ApplicationStatus.offer;
      case ApplicationStatus.offer:
        return ApplicationStatus.offer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Mes candidatures',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Suivez vos candidatures et préparez vos prochaines étapes en un coup d’œil.',
                          style: TextStyle(color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NewApplicationScreen()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppColors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.applications.length} candidatures suivies',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Ajoutez des notes après vos entretiens pour garder l’historique complet dans l’app.',
                            style: TextStyle(color: AppColors.textLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...user.applications.map((application) {
                final job = _jobFor(application.jobId);
                final statusColors = _statusColors(application.status);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE7EFFC),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                application.company.characters.first,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColors.background,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                application.status.label,
                                style: TextStyle(
                                  color: statusColors.text,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(icon: Icons.description, text: application.appliedOn),
                        _DetailRow(icon: Icons.schedule, text: application.lastUpdate),
                        if (application.nextStep != null)
                          _DetailRow(icon: Icons.check_circle, text: application.nextStep!),
                        if (job != null)
                          _DetailRow(
                            icon: Icons.work,
                            text:
                                '${job.location} • ${job.contract} • ${job.remoteType}',
                          ),
                        if (application.notes.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FB),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Notes personnelles',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...application.notes.map(
                                  (note) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.edit, size: 16, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            note,
                                            style: const TextStyle(color: AppColors.grayDark),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                context.read<AuthController>().addApplicationNote(
                                      application.id,
                                      _format('Relance envoyée'),
                                    );
                                AppSnackbar.show('Relance enregistrée pour cette candidature.', success: true);
                              },
                              child: const Text('Relancer'),
                            ),
                            OutlinedButton(
                              onPressed: application.status == ApplicationStatus.offer
                                  ? null
                                  : () {
                                      final nextStatus = _nextStatus(application.status);
                                      context.read<AuthController>().updateApplicationStatus(
                                            application.id,
                                            nextStatus,
                                            nextStep: _format('Prochaine étape'),
                                          );
                                      AppSnackbar.show('Statut mis à jour : ${nextStatus.label}.', success: true);
                                    },
                              child: const Text('Avancer le statut'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ApplicationDetailScreen(
                                    applicationId: application.id,
                                  ),
                                ),
                              ),
                              child: const Text('Ajouter une note'),
                            ),
                            if (job != null)
                              OutlinedButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => JobDetailsScreen(jobId: job.id),
                                  ),
                                ),
                                child: const Text('Voir l’offre'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  _StatusColors _statusColors(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.interview:
        return const _StatusColors(
          Color(0xFFE8F5FF),
          Color(0xFF1B6AE5),
        );
      case ApplicationStatus.inReview:
        return const _StatusColors(
          Color(0xFFFFF5E5),
          Color(0xFFE58B1B),
        );
      case ApplicationStatus.offer:
        return const _StatusColors(
          Color(0xFFE6F7EA),
          Color(0xFF2F9D6B),
        );
      case ApplicationStatus.sent:
        return const _StatusColors(
          Color(0xFFF0F2F7),
          Color(0xFF4B5563),
        );
    }
  }
}

class _StatusColors {
  const _StatusColors(this.background, this.text);
  final Color background;
  final Color text;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.grayDark),
            ),
          ),
        ],
      ),
    );
  }
}
