import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';
import '../search/search_screen.dart';
import 'alert_editor_screen.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes alertes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AlertEditorScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle alerte'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: user.alerts.length,
        itemBuilder: (context, index) {
          final alert = user.alerts[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            Text('${alert.location} • ${alert.frequency.label}',
                                style: const TextStyle(color: AppColors.textLight)),
                          ],
                        ),
                      ),
                      Switch(
                        value: alert.active,
                        onChanged: (_) => auth.toggleAlertActivation(alert.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(alert.keywords.join(' · '),
                      style: const TextStyle(color: AppColors.primary)),
                  Text('Dernier envoi : ${alert.lastRun}',
                      style: const TextStyle(color: AppColors.grayDark)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AlertEditorScreen(alertId: alert.id),
                          ),
                        ),
                        icon: const Icon(Icons.tune),
                        label: const Text('Modifier'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SearchScreen(alertId: alert.id),
                          ),
                        ),
                        icon: const Icon(Icons.search),
                        label: const Text('Voir les offres'),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Supprimer l’alerte'),
                              content: Text('Voulez-vous retirer l’alerte « ${alert.title} » ?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Annuler')),
                                TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Supprimer')),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            auth.deleteAlert(alert.id);
                            AppSnackbar.show('Alerte supprimée.', success: true);
                          }
                        },
                        icon: const Icon(Icons.delete, color: AppColors.danger),
                        label: const Text('Supprimer',
                            style: TextStyle(color: AppColors.danger)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
