import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../data/companies.dart';
import '../../data/job_offers.dart';
import '../../models/company.dart';
import '../../models/job_offer.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/job_card.dart';
import '../jobs/job_details_screen.dart';

class CompanyDetailsScreen extends StatelessWidget {
  const CompanyDetailsScreen({super.key, required this.companyId});

  final String companyId;

  Company? get _company {
    for (final company in companies) {
      if (company.id == companyId) {
        return company;
      }
    }
    return null;
  }

  List<JobOffer> get _relatedJobs {
    final company = _company;
    if (company == null) return [];
    return jobOffers
        .where((job) => job.companyId == company.id ||
            job.company.toLowerCase() == company.name.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    final company = _company;
    if (company == null || user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Entreprise introuvable.')),
      );
    }

    final jobs = _relatedJobs;

    return Scaffold(
      appBar: AppBar(title: Text(company.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF3FB),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    company.name.characters.first,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    Text(company.location,
                        style: const TextStyle(color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              company.description,
              style: const TextStyle(color: AppColors.grayDark, height: 1.5),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                _InfoChip(icon: Icons.apartment, text: company.industry),
                _InfoChip(icon: Icons.people, text: '${company.employees} collaborateurs'),
                _InfoChip(icon: Icons.work, text: '${company.openRoles} postes ouverts'),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: company.culture
                  .map((value) => Chip(label: Text(value)))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Offres disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            if (jobs.isEmpty)
              const _EmptyJobs()
            else
              ...jobs.map((job) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: JobCard(
                      job: job,
                      isFavorite: user.favorites.contains(job.id),
                      onToggleFavorite: () =>
                          context.read<AuthController>().toggleFavorite(job.id),
                      onApply: () => AppSnackbar.show(
                          'Votre candidature pour "${job.title}" a bien été envoyée.'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => JobDetailsScreen(jobId: job.id),
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

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
          Text(text, style: const TextStyle(color: AppColors.textLight)),
        ],
      ),
    );
  }
}

class _EmptyJobs extends StatelessWidget {
  const _EmptyJobs();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: const [
          Icon(Icons.inbox, size: 28, color: AppColors.primary),
          SizedBox(height: 12),
          Text(
            'Pas d’offre actuellement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Revenez bientôt, de nouvelles opportunités arrivent régulièrement.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
