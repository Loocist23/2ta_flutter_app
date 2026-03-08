import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';
import 'signup_controller.dart';

class SignupStep4Screen extends StatelessWidget {
  final SignupController? signupController;

  const SignupStep4Screen({super.key, this.signupController});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => signupController ?? SignupController(),
      child: const _SignupStep4ScreenContent(),
    );
  }
}

class _SignupStep4ScreenContent extends StatefulWidget {
  const _SignupStep4ScreenContent();

  @override
  State<_SignupStep4ScreenContent> createState() => _SignupStep4ScreenContentState();
}

class _SignupStep4ScreenContentState extends State<_SignupStep4ScreenContent> {
  bool _isSubmitting = false;

  Future<void> _submitSignup(BuildContext context) async {
    final signupController = context.read<SignupController>();
    final authController = context.read<AuthController>();

    if (!_isSubmitting && signupController.canSubmit) {
      setState(() => _isSubmitting = true);

      try {
        await authController.signUpWithDetails(
          email: signupController.email,
          password: signupController.password,
          firstName: signupController.firstName,
          lastName: signupController.lastName,
          phone: signupController.phone,
          university: signupController.university,
          birthDate: signupController.birthDate!,
        );

        // Réinitialiser le controller pour les prochaines inscriptions
        signupController.reset();

        // Afficher un message de succès
        AppSnackbar.show('Compte créé avec succès ! Bienvenue sur 2TA.', success: true);

        // Retour à l'écran principal
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }

      } catch (error) {
        setState(() => _isSubmitting = false);
        
        String errorMessage = 'Une erreur est survenue lors de la création du compte.';
        if (error is Exception) {
          errorMessage = error.toString().replaceFirst('Exception: ', '');
        }

        print('[SIGNUP] Erreur finale: $errorMessage');

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Erreur d\'inscription'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(errorMessage),
                  const SizedBox(height: 16),
                  const Text(
                    'Si le problème persiste, veuillez vérifier :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Votre connexion internet'),
                  const Text('• Que toutes les informations sont correctes'),
                  const Text('• Qu\'aucun compte n\'existe déjà avec cet email'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupController = context.watch<SignupController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          signupController.getStepTitle(),
          style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE7F2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: AppColors.secondary1, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'Retrouvez toutes les opportunités d’alternance sur 2TA',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Étape 4/4: Vérifiez vos informations',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: AppColors.textLight),
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: signupController.progress,
                  backgroundColor: AppColors.grayLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4,
                ),
                const SizedBox(height: 24),
                _AuthCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Confirmation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vérifiez vos informations avant de finaliser votre inscription.',
                        style: TextStyle(fontSize: 15, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 24),
                      _InfoSummaryRow(
                        icon: Icons.email,
                        label: 'Email',
                        value: signupController.email,
                      ),
                      const SizedBox(height: 12),
                      _InfoSummaryRow(
                        icon: Icons.person,
                        label: 'Prénom',
                        value: signupController.firstName,
                      ),
                      const SizedBox(height: 12),
                      _InfoSummaryRow(
                        icon: Icons.person_outline,
                        label: 'Nom',
                        value: signupController.lastName,
                      ),
                      const SizedBox(height: 12),
                      if (signupController.phone.isNotEmpty)
                        _InfoSummaryRow(
                          icon: Icons.phone,
                          label: 'Téléphone',
                          value: signupController.phone,
                        ),
                      if (signupController.phone.isNotEmpty)
                        const SizedBox(height: 12),
                      _InfoSummaryRow(
                        icon: Icons.school,
                        label: 'Université',
                        value: signupController.university.isNotEmpty ? signupController.university : 'Non renseigné',
                      ),
                      const SizedBox(height: 12),
                      _InfoSummaryRow(
                        icon: Icons.cake,
                        label: 'Date de naissance',
                        value: signupController.birthDate != null
                            ? '${signupController.birthDate!.day}/${signupController.birthDate!.month}/${signupController.birthDate!.year}'
                            : 'Non renseigné',
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'En cliquant sur "Finaliser l\'inscription", vous acceptez nos Conditions Générales d\'Utilisation et notre Politique de Confidentialité.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _PrimaryButton(
                              label: 'Retour',
                              onPressed: () => Navigator.pop(context),
                              backgroundColor: Colors.white,
                              textColor: AppColors.primary,
                              borderColor: AppColors.gray,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PrimaryButton(
                              label: 'Finaliser l\'inscription',
                              onPressed: () => _submitSignup(context),
                              busy: _isSubmitting,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget pour afficher une ligne de résumé des informations
class _InfoSummaryRow extends StatelessWidget {
  const _InfoSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widgets réutilisés
class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    this.onPressed,
    this.busy = false,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.borderColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: borderColor == null
              ? BorderSide.none
              : BorderSide(color: borderColor!),
        ),
      ),
      child: busy
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
    );
  }
}