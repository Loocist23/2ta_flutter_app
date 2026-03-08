import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../data/companies.dart';
import '../../data/job_offers.dart';
import '../../models/company.dart';
import '../../models/job_offer.dart';
import '../../models/user.dart';
import '../../state/auth_controller.dart';
import '../../widgets/job_card.dart';
import '../companies/company_details_screen.dart';
import '../jobs/job_details_screen.dart';
import 'alert_editor_screen.dart';
import 'alerts_screen.dart';
import 'documents_screen.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  List<JobOffer> _favoriteJobs(AppUser user) {
    JobOffer? find(String id) {
      for (final job in jobOffers) {
        if (job.id == id) {
          return job;
        }
      }
      return null;
    }

    return user.favorites.map(find).whereType<JobOffer>().toList();
  }

  List<Company> _followedCompanies(AppUser user) {
    return companies
        .where((company) => user.followedCompanies.contains(company.id))
        .toList();
  }

  Future<void> _confirm(BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool destructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(destructive ? 'Supprimer' : 'Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final favorites = _favoriteJobs(user);
    final followed = _followedCompanies(user);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6F0FF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        user.avatarInitials,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          Text(user.title, style: const TextStyle(color: AppColors.textLight)),
                          Text(user.location, style: const TextStyle(color: AppColors.grayDark)),
                          if (user.phone != null)
                            Text(user.phone!, style: const TextStyle(color: AppColors.grayDark)),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (user.bio != null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    user.bio!,
                    style: const TextStyle(color: AppColors.grayDark, height: 1.4),
                  ),
                ),
              const SizedBox(height: 20),
              _Section(
                title: 'Mes CV & documents',
                actionLabel: 'Gérer',
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                ),
                child: Column(
                  children: user.cvs
                      .map((cv) => ListTile(
                            leading: const Icon(Icons.description, color: AppColors.primary),
                            title: Text(cv.name),
                            subtitle: Text(cv.updatedAt),
                            trailing: cv.isPrimary
                                ? const Chip(label: Text('CV principal'))
                                : null,
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              _Section(
                title: 'Mes alertes',
                actionLabel: 'Gérer',
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AlertsScreen()),
                ),
                child: Column(
                  children: user.alerts
                      .map((alert) => ListTile(
                            leading: const Icon(Icons.notifications, color: AppColors.primary),
                            title: Text(alert.title),
                            subtitle: Text('${alert.location} • ${alert.frequency.label}'),
                            trailing: Switch(
                              value: alert.active,
                              onChanged: (_) => auth.toggleAlertActivation(alert.id),
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AlertEditorScreen(alertId: alert.id),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              _Section(
                title: 'Mes favoris',
                child: favorites.isEmpty
                    ? const _EmptyPlaceholder(
                        icon: Icons.bookmark,
                        title: 'Ajoutez des offres à vos favoris',
                        subtitle: 'Retrouvez-les ici pour candidater rapidement.',
                      )
                    : Column(
                        children: favorites
                            .map((job) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: JobCard(
                                    job: job,
                                    isFavorite: true,
                                    onToggleFavorite: () => auth.toggleFavorite(job.id),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => JobDetailsScreen(jobId: job.id),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 20),
              _Section(
                title: 'Entreprises suivies',
                child: followed.isEmpty
                    ? const _EmptyPlaceholder(
                        icon: Icons.people,
                        title: 'Suivez vos entreprises préférées',
                        subtitle:
                            'Depuis une fiche entreprise, suivez-la pour être alerté des nouvelles offres.',
                      )
                    : Column(
                        children: followed
                            .map((company) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFE6F0FF),
                                    child: Text(
                                      company.name.characters.first,
                                      style: const TextStyle(color: AppColors.primary),
                                    ),
                                  ),
                                  title: Text(company.name),
                                  subtitle: Text(company.location),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CompanyDetailsScreen(companyId: company.id),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 20),
              _Section(
                title: 'Paramètres',
                child: Column(
                  children: [
                    SwitchListTile(
                      value: user.settings.pushNotifications,
                      onChanged: (value) => auth.updateSettings(pushNotifications: value),
                      title: const Text('Notifications push'),
                    ),
                    SwitchListTile(
                      value: user.settings.emailSubscriptions,
                      onChanged: (value) => auth.updateSettings(emailSubscriptions: value),
                      title: const Text('Emails hebdomadaires'),
                    ),
                    ListTile(
                      title: const Text('Gestion des cookies'),
                      subtitle: Text(user.settings.cookieConsent.label),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => auth.updateSettings(
                        cookieConsent: user.settings.cookieConsent == CookieConsent.complete
                            ? CookieConsent.essential
                            : CookieConsent.complete,
                      ),
                    ),
                    SwitchListTile(
                      value: user.settings.accessibilityMode,
                      onChanged: (value) => auth.updateSettings(accessibilityMode: value),
                      title: const Text('Mode accessibilité'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SecurityScreen()),
                ),
                icon: const Icon(Icons.lock),
                label: Text(user.hasPassword
                    ? 'Modifier mon mot de passe'
                    : 'Créer un mot de passe'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _confirm(
                  context,
                  title: 'Déconnexion',
                  message: 'Vous serez déconnecté de votre session actuelle.',
                  onConfirm: () => auth.signOut(),
                ),
                child: const Text('Me déconnecter'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _confirm(
                  context,
                  title: 'Supprimer mon compte',
                  message:
                      'Cette action est définitive. Toutes vos données et vos candidatures seront supprimées.',
                  destructive: true,
                  onConfirm: () => auth.deleteAccount(),
                ),
                child: const Text(
                  'Supprimer mon compte',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(color: AppColors.grayDark),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
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
