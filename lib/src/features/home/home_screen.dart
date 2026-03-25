import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/company.dart';
import '../../models/job_offer.dart';
import '../../models/user.dart';
import '../../state/auth_controller.dart';
import '../../services/data_service.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/job_card.dart';
import '../companies/companies_screen.dart';
import '../companies/company_details_screen.dart';
import '../jobs/job_details_screen.dart';
import '../search/search_screen.dart';
import '../shell/main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Load data when screen is first shown
      final dataService = context.read<DataService>();
      dataService.loadJobOffers();
      dataService.loadCompanies();
    }
  }

  void _openSearch(BuildContext context, {String? alertId}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SearchScreen(alertId: alertId)),
    );
  }

  void _openCompanies(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CompaniesScreen()),
    );
  }

  void _openCompany(BuildContext context, String companyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompanyDetailsScreen(companyId: companyId),
      ),
    );
  }

  void _openJob(BuildContext context, JobOffer job) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => JobDetailsScreen(jobId: job.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final dataService = context.watch<DataService>();
    final user = auth.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final activeAlerts = user.alerts.where((alert) => alert.active).toList();
    final jobOffers = dataService.jobOffers;
    final loadingJobs = dataService.loadingJobs;
    final jobsError = dataService.jobsError;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Avatar(initials: user.avatarInitials),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bonjour ${user.name.split(' ').first} 👋',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${user.title} • ${user.location}',
                                style: const TextStyle(color: AppColors.textLight),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => MainTabScope.of(context).onTabSelected(1),
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.notifications,
                                    color: AppColors.primary),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF715B),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    user.notifications
                                        .where((notification) => !notification.read)
                                        .length
                                        .toString(),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _StatCard(
                          icon: Icons.bar_chart,
                          value: user.stats.profileViews.toString(),
                          label: 'vues profil',
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.mail,
                          value: user.stats.recruiterMessages.toString(),
                          label: 'messages recruteurs',
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.inbox,
                          value:
                              user.stats.applicationsInProgress.toString(),
                          label: 'candidatures',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'Mes alertes actives',
                      actionLabel: 'Créer une alerte',
                      onAction: () => _openSearch(context),
                    ),
                    const SizedBox(height: 12),
                    if (activeAlerts.isEmpty)
                      _EmptyCard(
                        icon: Icons.notifications_active,
                        title: 'Activez votre première alerte',
                        subtitle:
                            'Recevez les offres adaptées dès leur publication.',
                      )
                    else ...[
                      for (final alert in activeAlerts)
                        _AlertCard(
                          alert: alert,
                          onTap: () => _openSearch(context, alertId: alert.id),
                        ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Offres recommandées',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (loadingJobs)
                      const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ))
                    else if (jobsError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Failed to load job offers: ${jobsError!}',
                          style: TextStyle(color: AppColors.error),
                        ),
                      )
                    else if (jobOffers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('No job offers available at the moment.'),
                      )
                    else
                      ...jobOffers.map((job) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: JobCard(
                              job: job,
                              isFavorite: user.favorites.contains(job.id),
                              onToggleFavorite: () =>
                                  context.read<AuthController>().toggleFavorite(job.id),
                              onApply: () {
                                AppSnackbar.show(
                                  'Votre candidature pour "${job.title}" a bien été envoyée.',
                                );
                              },
                              onTap: () => _openJob(context, job),
                            ),
                          )),
                    const SizedBox(height: 12),
                    const Text(
                      'Les tendances du moment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFE6F0FF),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.textLight, fontSize: 13),
            )
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, required this.onTap});

  final UserAlert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${alert.location} • ${alert.frequency.label}',
                style: const TextStyle(color: AppColors.textLight, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                alert.keywords.join(' · '),
                style: const TextStyle(color: AppColors.primary, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Dernière alerte : ${alert.lastRun}',
                style: const TextStyle(color: AppColors.grayDark, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.description});

  final String topic;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            topic,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: AppColors.textLight, height: 1.35),
          )
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.company, required this.onTap});

  final Company company;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${company.openRoles} postes ouverts',
                style: const TextStyle(color: AppColors.textLight,
                    fontSize: 13),
              ),
              Text(
                company.location,
                style: const TextStyle(color: AppColors.grayDark, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

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
        children: [
          Icon(icon, size: 32, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
