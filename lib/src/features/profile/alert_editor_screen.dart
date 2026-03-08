import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/user.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';

class AlertEditorScreen extends StatefulWidget {
  const AlertEditorScreen({super.key, this.alertId});

  final String? alertId;

  @override
  State<AlertEditorScreen> createState() => _AlertEditorScreenState();
}

class _AlertEditorScreenState extends State<AlertEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _keywordsController;
  late TextEditingController _locationController;
  AlertFrequency _frequency = AlertFrequency.daily;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();
    UserAlert? alert;
    if (widget.alertId != null) {
      for (final item in auth.user?.alerts ?? []) {
        if (item.id == widget.alertId) {
          alert = item;
          break;
        }
      }
    }
    _titleController = TextEditingController(text: alert?.title ?? '');
    _keywordsController =
        TextEditingController(text: alert?.keywords.join(', ') ?? '');
    _locationController = TextEditingController(text: alert?.location ?? '');
    _frequency = alert?.frequency ?? AlertFrequency.daily;
    _active = alert?.active ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _keywordsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final keywords = _keywordsController.text
        .split(',')
        .map((keyword) => keyword.trim())
        .where((keyword) => keyword.isNotEmpty)
        .toList();
    final location = _locationController.text.trim();

    if (title.isEmpty) {
      AppSnackbar.show('Nommez votre alerte pour la retrouver facilement.', success: false);
      return;
    }
    if (keywords.isEmpty) {
      AppSnackbar.show('Ajoutez au moins un mot-clé séparé par une virgule.', success: false);
      return;
    }
    if (location.isEmpty) {
      AppSnackbar.show('Indiquez une ville, une région ou Télétravail.', success: false);
      return;
    }

    final auth = context.read<AuthController>();
    if (widget.alertId != null) {
      auth.updateAlert(
        widget.alertId!,
        title: title,
        keywords: keywords,
        location: location,
        frequency: _frequency,
        active: _active,
      );
      AppSnackbar.show('Alerte mise à jour.', success: true);
    } else {
      auth.createAlert(
        title: title,
        keywords: keywords,
        location: location,
        frequency: _frequency,
        active: _active,
      );
      AppSnackbar.show('Alerte créée.', success: true);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alertId != null ? 'Éditer une alerte' : 'Nouvelle alerte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Field(label: 'Titre de l’alerte', controller: _titleController),
            const SizedBox(height: 16),
            _Field(
              label: 'Mots-clés (séparés par des virgules)',
              controller: _keywordsController,
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Localisation',
              controller: _locationController,
            ),
            const SizedBox(height: 16),
            const Text(
              'Fréquence d’envoi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: AlertFrequency.values.map((frequency) {
                final selected = _frequency == frequency;
                return ChoiceChip(
                  label: Text(frequency.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _frequency = frequency),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _active,
              onChanged: (value) => setState(() => _active = value),
              title: const Text('Alerte active'),
              subtitle: const Text(
                'Désactivez-la pour suspendre temporairement les notifications.',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: Text(widget.alertId != null
                    ? 'Enregistrer les modifications'
                    : 'Créer mon alerte'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

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
        ),
      ],
    );
  }
}
