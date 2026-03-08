import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/user.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';
import '../applications/application_detail_screen.dart';
import '../search/search_screen.dart';
import '../jobs/job_details_screen.dart';

enum _FilterValue { all, unread, application, alert }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  _FilterValue _filter = _FilterValue.all;

  void _openLink(BuildContext context, NotificationLink link) {
    switch (link.type) {
      case NotificationLinkType.application:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ApplicationDetailScreen(applicationId: link.targetId),
          ),
        );
        break;
      case NotificationLinkType.alert:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SearchScreen(alertId: link.targetId)),
        );
        break;
      case NotificationLinkType.job:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => JobDetailsScreen(jobId: link.targetId)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final notifications = user.notifications.where((notification) {
      switch (_filter) {
        case _FilterValue.all:
          return true;
        case _FilterValue.unread:
          return !notification.read;
        case _FilterValue.application:
          return notification.type == NotificationType.application;
        case _FilterValue.alert:
          return notification.type == NotificationType.alert;
      }
    }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: auth.markAllNotificationsRead,
                    icon: const Icon(Icons.check_circle, color: AppColors.primary),
                    label: const Text('Tout marquer comme lu'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _FilterValue.values
                    .map((value) => ChoiceChip(
                          label: Text(_labelForFilter(value)),
                          selected: _filter == value,
                          onSelected: (_) => setState(() => _filter = value),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              if (notifications.isEmpty)
                const Expanded(
                  child: Center(
                    child: _EmptyState(),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final isUnread = !notification.read;
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            auth.markNotificationRead(notification.id);
                            if (notification.link != null) {
                              _openLink(context, notification.link!);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _IconBubble(type: notification.type),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notification.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.text,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            notification.date,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.grayDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        notification.message,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.grayDark,
                                          height: 1.4,
                                        ),
                                      ),
                                      if (isUnread)
                                        Container(
                                          margin: const EdgeInsets.only(top: 6),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFE4D8),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'Nouvelle',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFFF7844),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppColors.danger),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Supprimer la notification'),
                                        content: Text(
                                          'Voulez-vous retirer la notification « ${notification.title} » ?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Supprimer'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (!context.mounted) return;
                                    if (confirmed == true) {
                                      context
                                          .read<AuthController>()
                                          .removeNotification(notification.id);
                                      AppSnackbar.show('Notification supprimée.', success: true);
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelForFilter(_FilterValue value) {
    switch (value) {
      case _FilterValue.all:
        return 'Toutes';
      case _FilterValue.unread:
        return 'Non lues';
      case _FilterValue.application:
        return 'Candidatures';
      case _FilterValue.alert:
        return 'Alertes';
    }
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (type) {
      case NotificationType.application:
        icon = Icons.inbox;
        break;
      case NotificationType.alert:
        icon = Icons.notifications_active;
        break;
      case NotificationType.information:
        icon = Icons.star;
        break;
    }
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFEDF4FF),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.primary),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.notifications, size: 36, color: AppColors.primary),
        SizedBox(height: 12),
        Text(
          'Aucune notification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Revenez bientôt, de nouvelles opportunités arrivent chaque jour.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textLight),
        ),
      ],
    );
  }
}
