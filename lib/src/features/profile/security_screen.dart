import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _deleteController = TextEditingController();
  String? _error;
  String? _success;
  bool _loading = false;
  bool _deleting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _deleteController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword(AuthController auth) async {
    final user = auth.user;
    if (user == null) return;

    setState(() {
      _error = null;
      _success = null;
      _loading = true;
    });

    if (_newController.text != _confirmController.text) {
      setState(() {
        _error = 'Les deux mots de passe ne correspondent pas.';
        _loading = false;
      });
      return;
    }

    try {
      await auth.updatePassword(
        currentPassword: user.hasPassword ? _currentController.text : null,
        newPassword: _newController.text,
      );
      setState(() {
        _success = 'Votre mot de passe a été mis à jour.';
      });
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
    } catch (error) {
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteAccount(AuthController auth) async {
    if (_deleteController.text != 'SUPPRIMER') {
      AppSnackbar.show('Tapez « SUPPRIMER » pour confirmer.', success: false);
      return;
    }

    setState(() => _deleting = true);
    await auth.deleteAccount();
    if (!mounted) return;
    setState(() => _deleting = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final providerDescription = auth.activeProvider == AuthProvider.google
        ? 'Vous êtes connecté via Google. Créez un mot de passe 2TA pour accéder à votre compte même sans Google.'
        : auth.activeProvider == AuthProvider.apple
            ? 'Vous utilisez Apple pour vous connecter. Vous pouvez ajouter un mot de passe 2TA pour vous connecter sur le web ou Android.'
            : 'Changez régulièrement votre mot de passe pour sécuriser vos données.';

    return Scaffold(
      appBar: AppBar(title: const Text('Sécurité & mot de passe')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.lock, color: AppColors.primary),
            title: const Text('Gestion du mot de passe'),
            subtitle: Text(providerDescription),
          ),
          if (user.hasPassword)
            TextField(
              controller: _currentController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _newController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          if (_success != null)
            Text(_success!, style: const TextStyle(color: AppColors.primary)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : () => _updatePassword(auth),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(user.hasPassword
                    ? 'Modifier mon mot de passe'
                    : 'Créer un mot de passe 2TA'),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.danger),
            title: const Text('Supprimer mon compte'),
            subtitle: const Text('Tapez « SUPPRIMER » pour activer le bouton et confirmer la suppression définitive.'),
          ),
          TextField(
            controller: _deleteController,
            decoration: const InputDecoration(hintText: 'SUPPRIMER'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _deleting ? null : () => _deleteAccount(auth),
            child: _deleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Supprimer mon compte'),
          ),
        ],
      ),
    );
  }
}
