import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _newDocumentController = TextEditingController();
  String? _editingId;
  final _renameController = TextEditingController();

  @override
  void dispose() {
    _newDocumentController.dispose();
    _renameController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, String cvId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le document'),
        content: const Text('Voulez-vous vraiment retirer ce document ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed == true) {
      context.read<AuthController>().removeCv(cvId);
      AppSnackbar.show('Document supprimé.', success: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes CV & documents')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Ajoutez plusieurs versions de vos CV, renommez-les et choisissez celui à utiliser par défaut lors de vos candidatures.',
            style: TextStyle(color: AppColors.textLight),
          ),
          const SizedBox(height: 20),
          ...user.cvs.map((cv) {
            final isEditing = _editingId == cv.id;
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: isEditing
                              ? TextField(
                                  controller: _renameController,
                                  autofocus: true,
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cv.name,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.text)),
                                    Text(cv.updatedAt,
                                        style: const TextStyle(
                                            color: AppColors.textLight)),
                                  ],
                                ),
                        ),
                        if (cv.isPrimary)
                          const Chip(label: Text('CV principal')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: [
                        if (isEditing)
                          FilledButton.icon(
                          onPressed: () {
                            final name = _renameController.text.trim();
                            if (name.isEmpty) {
                              AppSnackbar.show('Le nom du document ne peut pas être vide.', success: false);
                              return;
                            }
                            context.read<AuthController>().renameCv(cv.id, name);
                            AppSnackbar.show('Document renommé.', success: true);
                            setState(() => _editingId = null);
                          },
                            icon: const Icon(Icons.check),
                            label: const Text('Valider'),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _editingId = cv.id;
                                _renameController.text = cv.name;
                              });
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Renommer'),
                          ),
                        OutlinedButton.icon(
                          onPressed: () => context.read<AuthController>().setPrimaryCv(cv.id),
                          icon: Icon(
                            cv.isPrimary ? Icons.star : Icons.star_border,
                            color: AppColors.primary,
                          ),
                          label: const Text('Définir par défaut'),
                        ),
                        TextButton.icon(
                          onPressed: () => _confirmDelete(context, cv.id),
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
          }),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ajouter un document',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newDocumentController,
                    decoration: const InputDecoration(
                      hintText: 'Nom du fichier (ex : CV_mai_2025.pdf)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      final name = _newDocumentController.text.trim();
                      if (name.isEmpty) {
                        AppSnackbar.show('Veuillez nommer votre document.', success: false);
                        return;
                      }
                      context.read<AuthController>().addCv(name);
                      _newDocumentController.clear();
                      AppSnackbar.show('Document ajouté.', success: true);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter à ma bibliothèque'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
