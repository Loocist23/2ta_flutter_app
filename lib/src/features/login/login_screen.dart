import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';
import 'signup_controller.dart';
import 'signup_step1_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _resetController = TextEditingController();
  bool _resetMode = false;
  String? _error;
  String? _resetError;
  String? _resetSuccess;
  bool _processingReset = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _resetController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn(AuthController auth) async {
    setState(() => _error = null);
    try {
      // Mode connexion uniquement (l'inscription passe par le flow détaillé)
      await auth.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _fullNameController.text,
      );
      AppSnackbar.show('Connexion réussie.', success: true);
    } catch (error) {
      setState(() => _error = error is Exception ? error.toString().replaceFirst('Exception: ', '') : 'Une erreur inattendue est survenue.');
    }
  }

  void _navigateToSignupFlow(BuildContext context) {
    final signupController = SignupController();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupStep1Screen(signupController: signupController),
      ),
    );
  }

  Future<void> _handleReset(AuthController auth) async {
    setState(() {
      _resetError = null;
      _resetSuccess = null;
      _processingReset = true;
    });
    try {
      await auth.requestPasswordReset(_resetController.text);
      setState(() {
        _resetSuccess =
            'Nous venons de vous envoyer un email pour réinitialiser votre mot de passe.';
      });
    } catch (error) {
      setState(() {
        _resetError = error is Exception
            ? error.toString().replaceFirst('Exception: ', '')
            : 'Impossible d’envoyer le lien pour le moment.';
      });
    } finally {
      setState(() => _processingReset = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                  child: const Icon(Icons.work, color: AppColors.secondary1, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Retrouvez toutes les opportunités d’alternance sur 2TA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous pour accéder à votre espace personnel et découvrir toutes les opportunités d\'alternance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.textLight),
                ),
                const SizedBox(height: 32),
                _AuthCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Connexion',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choisissez votre méthode de connexion pour accéder à votre compte.',
                        style: TextStyle(fontSize: 15, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 18),
                      _PrimaryButton(
                        label: 'Continuer avec Google',
                        icon: Icons.login,
                        busy: auth.loading,
                        onPressed: auth.loading ? null : auth.signInWithGoogle,
                        backgroundColor: AppColors.secondary1,
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      _PrimaryButton(
                        label: 'Continuer avec Apple',
                        icon: Icons.apple,
                        busy: auth.loading,
                        onPressed: auth.loading ? null : auth.signInWithApple,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        borderColor: AppColors.gray,
                      ),
                      const SizedBox(height: 18),
                      // Bouton pour créer un compte
                      TextButton(
                        onPressed: () => _navigateToSignupFlow(context),
                        child: const Text(
                          'Vous n\'avez pas de compte ? Créez-en un',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: const [
                          Expanded(child: Divider(color: AppColors.grayLight)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('ou utilisez votre email', style: TextStyle(color: AppColors.textLight)),
                          ),
                          Expanded(child: Divider(color: AppColors.grayLight)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _LabeledField(
                        label: 'Adresse email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _LabeledField(
                        label: 'Mot de passe',
                        controller: _passwordController,
                        obscureText: true,
                        helper: '6 caractères minimum. Vous pourrez le modifier plus tard.',
                      ),
                      const SizedBox(height: 12),
                      _LabeledField(
                        label: 'Nom complet (facultatif)',
                        controller: _fullNameController,
                      ),
                      const SizedBox(height: 8),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        ),
                      _PrimaryButton(
                        label: 'Se connecter',
                        busy: auth.loading,
                        onPressed: auth.loading
                            ? null
                            : () => _handleEmailSignIn(auth),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _resetMode = !_resetMode;
                            _resetController.text = _emailController.text;
                            _resetError = null;
                            _resetSuccess = null;
                          });
                        },
                        child: Text(_resetMode ? 'Revenir à la connexion' : 'Mot de passe oublié ?'),
                      ),
                      if (_resetMode) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Réinitialiser mon mot de passe',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Indiquez votre adresse email pour recevoir un lien sécurisé de réinitialisation.',
                          style: TextStyle(fontSize: 14, color: AppColors.textLight),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _resetController,
                          decoration: const InputDecoration(
                            hintText: 'prenom.nom@email.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        if (_resetError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _resetError!,
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          ),
                        if (_resetSuccess != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _resetSuccess!,
                              style: const TextStyle(color: AppColors.primary),
                            ),
                          ),
                        const SizedBox(height: 10),
                        _PrimaryButton(
                          label: 'Envoyer le lien de réinitialisation',
                          busy: _processingReset,
                          onPressed: _processingReset
                              ? null
                              : () => _handleReset(auth),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'En continuant, vous acceptez nos Conditions Générales d’utilisation et notre politique de confidentialité.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textLight),
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
    this.icon,
    this.busy = false,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.borderColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
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
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: textColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.helper,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? helper;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
        ),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              helper!,
              style: const TextStyle(fontSize: 13, color: AppColors.textLight),
            ),
          ),
      ],
    );
  }
}
