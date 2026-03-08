import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import 'signup_controller.dart';
import 'signup_step3_screen.dart';

class SignupStep2Screen extends StatelessWidget {
  final SignupController? signupController;

  const SignupStep2Screen({super.key, this.signupController});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => signupController ?? SignupController(),
      child: const _SignupStep2ScreenContent(),
    );
  }
}

class _SignupStep2ScreenContent extends StatefulWidget {
  const _SignupStep2ScreenContent();

  @override
  State<_SignupStep2ScreenContent> createState() => _SignupStep2ScreenContentState();
}

class _SignupStep2ScreenContentState extends State<_SignupStep2ScreenContent> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _firstNameError;
  String? _lastNameError;
  String? _phoneError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validateFields() {
    final signupController = context.read<SignupController>();
    
    // Mettre à jour les valeurs dans le contrôleur d'abord
    signupController.firstName = _firstNameController.text.trim();
    signupController.lastName = _lastNameController.text.trim();
    signupController.phone = _phoneController.text.isEmpty ? '' : _phoneController.text;
    
    // Puis mettre à jour l'état local pour les messages d'erreur
    setState(() {
      // Validation prénom
      if (_firstNameController.text.trim().isEmpty) {
        _firstNameError = 'Veuillez renseigner votre prénom';
      } else {
        _firstNameError = null;
      }

      // Validation nom
      if (_lastNameController.text.trim().isEmpty) {
        _lastNameError = 'Veuillez renseigner votre nom';
      } else {
        _lastNameError = null;
      }

      // Validation téléphone (obligatoire)
      if (_phoneController.text.isEmpty) {
        _phoneError = 'Le numéro de téléphone est obligatoire';
      } else if (_phoneController.text.length != 10) {
        _phoneError = 'Numéro de téléphone invalide (10 chiffres)';
      } else {
        _phoneError = null;
      }
    });
    
    // Forcer la mise à jour de l'interface
    signupController.notifyListeners();
  }

  void _navigateToNextStep() {
    final signupController = context.read<SignupController>();
    
    // Mettre à jour les valeurs actuelles dans le contrôleur avant la validation
    signupController.firstName = _firstNameController.text.trim();
    signupController.lastName = _lastNameController.text.trim();
    signupController.phone = _phoneController.text;
    
    if (signupController.canGoToStep3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignupStep3Screen(signupController: signupController),
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
                  child: const Icon(Icons.person, color: AppColors.secondary1, size: 32),
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
                  'Étape 2/4: Complétez votre profil personnel',
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
                        'Informations personnelles',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ces informations nous aideront à personnaliser votre expérience.',
                        style: TextStyle(fontSize: 15, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 24),
                      _LabeledField(
                        label: 'Prénom',
                        controller: _firstNameController,
                        errorText: _firstNameError,
                        onChanged: (value) => setState(() => _firstNameError = null),
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: 'Nom',
                        controller: _lastNameController,
                        errorText: _lastNameError,
                        onChanged: (value) => setState(() => _lastNameError = null),
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: 'Numéro de téléphone*',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        errorText: _phoneError,
                        helper: 'Format: 0612345678',
                        onChanged: (value) => setState(() => _phoneError = null),
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
                              label: 'Continuer',
                              onPressed: _navigateToNextStep,
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

// Widgets réutilisés avec améliorations
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