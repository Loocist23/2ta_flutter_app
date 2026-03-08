import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import 'signup_controller.dart';
import 'signup_step2_screen.dart';

class SignupStep1Screen extends StatelessWidget {
  final SignupController? signupController;

  const SignupStep1Screen({super.key, this.signupController});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => signupController ?? SignupController(),
      child: const _SignupStep1ScreenContent(),
    );
  }
}

class _SignupStep1ScreenContent extends StatefulWidget {
  const _SignupStep1ScreenContent();

  @override
  State<_SignupStep1ScreenContent> createState() => _SignupStep1ScreenContentState();
}

class _SignupStep1ScreenContentState extends State<_SignupStep1ScreenContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateFields() {
    final signupController = context.read<SignupController>();
    
    // Mettre à jour les valeurs dans le contrôleur d'abord
    signupController.email = _emailController.text;
    signupController.password = _passwordController.text;
    signupController.confirmPassword = _confirmPasswordController.text;
    
    // Puis mettre à jour l'état local pour les messages d'erreur
    setState(() {
      // Validation email
      if (_emailController.text.isEmpty) {
        _emailError = 'Veuillez renseigner votre email';
      } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_emailController.text)) {
        _emailError = 'Email invalide';
      } else {
        _emailError = null;
      }

      // Validation mot de passe
      if (_passwordController.text.isEmpty) {
        _passwordError = 'Veuillez renseigner un mot de passe';
      } else if (_passwordController.text.length < 8) {
        _passwordError = '8 caractères minimum';
      } else if (!RegExp(r'[A-Za-z]').hasMatch(_passwordController.text)) {
        _passwordError = 'Au moins une lettre';
      } else if (!RegExp(r'[0-9]').hasMatch(_passwordController.text)) {
        _passwordError = 'Au moins un chiffre';
      } else {
        _passwordError = null;
      }

      // Validation confirmation mot de passe
      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = 'Veuillez confirmer votre mot de passe';
      } else if (_confirmPasswordController.text != _passwordController.text) {
        _confirmPasswordError = 'Les mots de passe ne correspondent pas';
      } else {
        _confirmPasswordError = null;
      }
    });
    
    // Forcer la mise à jour de l'interface
    signupController.notifyListeners();
  }

  void _navigateToNextStep() {
    final signupController = context.read<SignupController>();
    
    // Mettre à jour les valeurs actuelles dans le contrôleur avant la validation
    signupController.email = _emailController.text;
    signupController.password = _passwordController.text;
    signupController.confirmPassword = _confirmPasswordController.text;
    
    if (signupController.canGoToStep2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignupStep2Screen(signupController: signupController),
        ),
      );
    } else {
      _validateFields();
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
                  child: const Icon(Icons.work, color: AppColors.secondary1, size: 32),
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
                  'Étape 1/4: Créez vos identifiants de connexion',
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
                        'Créer votre compte',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ces informations serviront à vous connecter à votre compte.',
                        style: TextStyle(fontSize: 15, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 24),
                      _LabeledField(
                        label: 'Adresse email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        onChanged: (value) => setState(() => _emailError = null),
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: 'Mot de passe',
                        controller: _passwordController,
                        obscureText: true,
                        errorText: _passwordError,
                        helper: '8 caractères minimum avec au moins une lettre et un chiffre',
                        onChanged: (value) => setState(() => _passwordError = null),
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: 'Confirmer le mot de passe',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        errorText: _confirmPasswordError,
                        onChanged: (value) => setState(() => _confirmPasswordError = null),
                      ),
                      const SizedBox(height: 24),
                      _PrimaryButton(
                        label: 'Continuer',
                        onPressed: _navigateToNextStep,
                      ),
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

// Réutilisation des widgets existants
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
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final Color backgroundColor;
  final Color textColor;

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

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.helper,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? helper;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;

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
          decoration: InputDecoration(
            errorText: errorText,
            errorStyle: const TextStyle(color: AppColors.danger),
          ),
          onChanged: onChanged,
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