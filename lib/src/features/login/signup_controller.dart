import 'package:flutter/foundation.dart';

class SignupController extends ChangeNotifier {
  // Données du formulaire d'inscription
  String email = '';
  String password = '';
  String confirmPassword = '';
  String firstName = '';
  String lastName = '';
  String phone = '';
  String university = '';
  DateTime? birthDate;

  // Navigation entre étapes
  int currentStep = 1;
  static const int totalSteps = 4;

  // Validation pour chaque étape
  bool get canGoToStep2 {
    if (email.isEmpty) return false;
    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(email)) return false;
    if (password.length < 8) return false;
    if (password != confirmPassword) return false;
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    return true;
  }

  bool get canGoToStep3 {
    if (firstName.trim().isEmpty) return false;
    if (lastName.trim().isEmpty) return false;
    if (phone.isNotEmpty && phone.length != 10) return false;
    return true;
  }

  bool get canGoToStep4 {
    if (university.trim().isEmpty) return false;
    if (birthDate == null) return false;
    if (phone.trim().isEmpty || phone.length != 10) return false;
    
    // Vérifier que l'utilisateur a au moins 15 ans
    final now = DateTime.now();
    final age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || (now.month == birthDate!.month && now.day < birthDate!.day)) {
      if (age < 15) return false;
    } else {
      if (age < 15) return false;
    }
    
    return true;
  }

  bool get canSubmit {
    return canGoToStep4; // Même validation que l'étape 4
  }

  void nextStep() {
    if (currentStep < totalSteps) {
      currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (currentStep > 1) {
      currentStep--;
      notifyListeners();
    }
  }

  void reset() {
    email = '';
    password = '';
    confirmPassword = '';
    firstName = '';
    lastName = '';
    phone = '';
    university = '';
    birthDate = null;
    currentStep = 1;
    notifyListeners();
  }

  // Méthode pour obtenir le titre de l'étape actuelle
  String getStepTitle() {
    switch (currentStep) {
      case 1: return 'Créer votre compte';
      case 2: return 'Informations personnelles';
      case 3: return 'Informations étudiant';
      case 4: return 'Confirmation';
      default: return 'Inscription';
    }
  }

  // Méthode pour obtenir la description de l'étape actuelle
  String getStepDescription() {
    switch (currentStep) {
      case 1: return 'Étape 1/4';
      case 2: return 'Étape 2/4';
      case 3: return 'Étape 3/4';
      case 4: return 'Étape 4/4';
      default: return '';
    }
  }

  // Calcul de la progression
  double get progress => currentStep / totalSteps;
}