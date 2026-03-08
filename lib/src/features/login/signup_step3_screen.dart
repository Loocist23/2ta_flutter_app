import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import 'signup_controller.dart';
import 'signup_step4_screen.dart';

class SignupStep3Screen extends StatelessWidget {
  final SignupController? signupController;

  const SignupStep3Screen({super.key, this.signupController});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => signupController ?? SignupController(),
      child: const _SignupStep3ScreenContent(),
    );
  }
}

class _SignupStep3ScreenContent extends StatefulWidget {
  const _SignupStep3ScreenContent();

  @override
  State<_SignupStep3ScreenContent> createState() => _SignupStep3ScreenContentState();
}

class _SignupStep3ScreenContentState extends State<_SignupStep3ScreenContent> {
  final _universityController = TextEditingController();
  DateTime? _selectedBirthDate;
  String? _universityError;
  String? _birthDateError;

  @override
  void dispose() {
    _universityController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // 18 ans par défaut
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 15)), // 15 ans minimum
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary, // Couleur de l'en-tête
              onPrimary: Colors.white, // Couleur du texte de l'en-tête
              onSurface: AppColors.text, // Couleur du texte
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // Couleur du texte des boutons
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateError = null;
        context.read<SignupController>().birthDate = picked;
      });
    }
  }

  void _validateFields() {
    final signupController = context.read<SignupController>();
    
    // Mettre à jour les valeurs dans le contrôleur d'abord
    signupController.university = _universityController.text.trim();
    signupController.birthDate = _selectedBirthDate;
    
    // Puis mettre à jour l'état local pour les messages d'erreur
    setState(() {
      // Validation université
      if (_universityController.text.trim().isEmpty) {
        _universityError = 'Veuillez renseigner votre université';
      } else {
        _universityError = null;
      }

      // Validation date de naissance
      if (_selectedBirthDate == null) {
        _birthDateError = 'Veuillez sélectionner votre date de naissance';
      } else {
        _birthDateError = null;
      }
    });
    
    // Forcer la mise à jour de l'interface
    signupController.notifyListeners();
  }

  void _navigateToNextStep() {
    final signupController = context.read<SignupController>();
    
    // Mettre à jour les valeurs actuelles dans le contrôleur avant la validation
    signupController.university = _universityController.text.trim();
    signupController.birthDate = _selectedBirthDate;
    
    if (signupController.canGoToStep4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignupStep4Screen(signupController: signupController),
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
                  child: const Icon(Icons.school, color: AppColors.secondary1, size: 32),
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
                  'Étape 3/4: Informations sur votre formation',
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
                        'Informations étudiant',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ces informations nous aideront à vous proposer des offres adaptées à votre profil.',
                        style: TextStyle(fontSize: 15, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 24),
                      _LabeledField(
                        label: 'Université / École',
                        controller: _universityController,
                        errorText: _universityError,
                        helper: 'Ex: Université de Paris, Ecole 42, etc.',
                        onChanged: (value) => setState(() => _universityError = null),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date de naissance',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectBirthDate(context),
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                errorText: _birthDateError,
                                errorStyle: const TextStyle(color: AppColors.danger),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: AppColors.gray),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedBirthDate == null
                                          ? 'Sélectionnez votre date de naissance'
                                          : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
                                      style: TextStyle(
                                        color: _selectedBirthDate == null ? AppColors.textLight : AppColors.text,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today, color: AppColors.textLight, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Vous devez avoir au moins 15 ans',
                            style: TextStyle(fontSize: 13, color: AppColors.textLight),
                          ),
                        ],
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