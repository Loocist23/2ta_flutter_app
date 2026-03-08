import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../data/companies.dart';
import '../../data/job_offers.dart';
import '../../models/company.dart';
import '../../models/job_offer.dart';
import '../../models/user.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key, required this.jobId});

  final String jobId;

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  String? _selectedCvId;
  final _messageController = TextEditingController();
  bool _includeProfile = true;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  JobOffer? get _job {
    for (final job in jobOffers) {
      if (job.id == widget.jobId) {
        return job;
      }
    }
    return null;
  }

  Company? get _company {
    final job = _job;
    if (job == null) return null;
    for (final company in companies) {
      if (company.id == job.companyId ||
          company.name.toLowerCase() == job.company.toLowerCase()) {
        return company;
      }
    }
    return null;
  }

  Future<void> _openApplySheet(BuildContext context, AuthController auth) async {
    final user = auth.user;
    if (user == null) return;
    _selectedCvId ??= user.cvs.isNotEmpty ? user.cvs.first.id : null;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Envoyer ma candidature',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Choisir un CV'),
                  const SizedBox(height: 8),
                  if (user.cvs.isEmpty)
                    const Text(
                      'Ajoutez un CV depuis votre profil pour candidater.',
                      style: TextStyle(color: AppColors.textLight),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCvId,
                      items: user.cvs
                          .map(
                            (cv) => DropdownMenuItem(
                              value: cv.id,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cv.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Text(cv.updatedAt,
                                      style: const TextStyle(
                                          color: AppColors.textLight)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setStateModal(() {
                        _selectedCvId = value;
                      }),
                      decoration: const InputDecoration(
                        labelText: 'CV à joindre',
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message au recruteur',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _includeProfile,
                    onChanged: (value) => setStateModal(() {
                      _includeProfile = value;
                    }),
                    title: const Text('Partager mon profil complet'),
                    subtitle: const Text(
                      'Inclut votre expérience et vos coordonnées avec la candidature.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selectedCvId == null
                          ? null
                          : () => Navigator.pop(context, true),
                      child: const Text('Envoyer ma candidature'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );

    if (confirmed == true && _job != null) {
      final notes = <String>[_includeProfile
          ? 'Profil partagé automatiquement avec la candidature mobile'
          : 'Candidature envoyée sans partage automatique'];
      if (_messageController.text.trim().isNotEmpty) {
        notes.add('Message au recruteur : ${_messageController.text.trim()}');
      }

      auth.addApplication(
        jobId: _job!.id,
        company: _job!.company,
        title: _job!.title,
        status: ApplicationStatus.sent,
        appliedOn: 'Candidature envoyée le ${DateTime.now().day}/${DateTime.now().month}',
        nextStep: _includeProfile ? 'Suivre la réponse recruteur' : null,
        notes: notes,
      );
      AppSnackbar.show('Votre candidature a été ajoutée à votre suivi.', success: true);
      _messageController.clear();
      _includeProfile = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    final job = _job;
    if (job == null || user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Offre introuvable.')),
      );
    }
    final company = _company;
    final isFavorite = user.favorites.contains(job.id);
    final isFollowing = company != null &&
        user.followedCompanies.contains(company.id);

    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${job.company} • ${job.location}',
                        style: const TextStyle(color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_outline,
                    color:
                        isFavorite ? AppColors.primary : AppColors.gray,
                  ),
                  onPressed: () => auth.toggleFavorite(job.id),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                _Pill(text: job.contract, icon: Icons.work),
                _Pill(text: job.remoteType, icon: Icons.public),
                _Pill(text: job.postedAt, icon: Icons.schedule),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'À propos du poste',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              job.description,
              style: const TextStyle(color: AppColors.grayDark, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Compétences recherchées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: job.tags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
            const SizedBox(height: 20),
            if (company != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
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
                            color: Color(0xFFEEF3FB),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            company.name.characters.first,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            Text(company.location,
                                style: const TextStyle(
                                    color: AppColors.textLight)),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      company.description,
                      style:
                          const TextStyle(color: AppColors.grayDark, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        _Pill(text: company.industry, icon: Icons.apartment),
                        _Pill(
                            text: '${company.employees} collaborateurs',
                            icon: Icons.people),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: company.culture
                          .map((value) => Chip(label: Text(value)))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => isFollowing
                                ? auth.unfollowCompany(company.id)
                                : auth.followCompany(company.id),
                            icon: Icon(
                              isFollowing ? Icons.favorite : Icons.favorite_border,
                              color: isFollowing
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                            label: Text(isFollowing
                                ? 'Entreprise suivie'
                                : 'Suivre cette entreprise'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isFollowing
                                  ? AppColors.primary
                                  : Colors.white,
                              foregroundColor:
                                  isFollowing ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bar_chart, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        job.salary,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openApplySheet(context, auth),
                      icon: const Icon(Icons.send),
                      label: const Text('Postuler depuis l’app'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
