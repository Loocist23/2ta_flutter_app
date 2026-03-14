import 'package:dio/dio.dart';

import 'api_service.dart';

class AuthApiService {
  final ApiService _apiService;

  AuthApiService(this._apiService);

  /// Login avec email/mot de passe (backend de production)
  Future<String> loginWithEmailPassword(String email, String password) async {
    try {
      print('[AUTH] Tentative de login pour: $email');
      
      // Utiliser le format qui fonctionne sur le backend de production
      final response = await _apiService.post('/login_check', data: {
        'username': email, // Format du backend de production
        'password': password,
      });

      print('[AUTH] Réponse de login reçue. Status: ${response.statusCode}');
      print('[AUTH] Headers: ${response.headers}');
      print('[AUTH] Body: ${response.data}');

      // Extraire le token - le backend de production le retourne dans le body
      if (response.data is Map && response.data.containsKey('token')) {
        return response.data['token'] as String;
      }
      
      // Si pas dans le body, vérifier dans les headers (fallback)
      final token = response.headers['authorization']?.first;
      if (token != null && token.startsWith('Bearer ')) {
        return token.replaceFirst('Bearer ', '');
      }
      
      throw Exception('Token non reçu dans la réponse. Veuillez vérifier vos informations de connexion.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Email ou mot de passe incorrect.');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Requête de login invalide. Veuillez vérifier les champs.');
      }
      _handleAuthError(e);
      rethrow;
    }
  }

  /// Inscription/connexion avec OAuth (Google)
  Future<String> loginWithGoogle({
    required String email,
    required String firstName,
    required String lastName,
    required String googleId,
    String? university,
    String? birthDate,
  }) async {
    try {
      final response = await _apiService.post('/connect/register-oauth', data: {
        'email': email,
        'userType': 'student',
        'firstName': firstName,
        'lastName': lastName,
        'googleId': googleId,
        if (university != null) 'university': university,
        if (birthDate != null) 'birth_date': birthDate,
      });

      final token = response.data['token'];
      if (token == null || token.isEmpty) {
        throw Exception('Token non reçu dans la réponse');
      }

      return token;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Un compte existe déjà avec cet email.');
      }
      _handleAuthError(e);
      rethrow;
    }
  }

  /// Inscription/connexion avec OAuth (Apple)
  Future<String> loginWithApple({
    required String email,
    required String firstName,
    required String lastName,
    required String appleId,
    String? university,
    String? birthDate,
  }) async {
    try {
      final response = await _apiService.post('/connect/register-oauth', data: {
        'email': email,
        'userType': 'student',
        'firstName': firstName,
        'lastName': lastName,
        'linkedinId': appleId, // Utiliser linkedinId pour Apple aussi
        if (university != null) 'university': university,
        if (birthDate != null) 'birth_date': birthDate,
      });

      final token = response.data['token'];
      if (token == null || token.isEmpty) {
        throw Exception('Token non reçu dans la réponse');
      }

      return token;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Un compte existe déjà avec cet email.');
      }
      _handleAuthError(e);
      rethrow;
    }
  }

  /// Récupérer les informations de l'utilisateur connecté
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiService.get('/me');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token expiré - déclencher la déconnexion automatique
        _apiService.clearAuthToken();
        throw Exception('Votre session a expiré. Veuillez vous reconnecter.');
      }
      _handleAuthError(e);
      rethrow;
    }
  }

  /// Demander une réinitialisation de mot de passe
  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiService.post('/mail/subscribe-mail-check', data: {
        'email': email,
        'firstname': '',
        'name': '',
      });
    } on DioException catch (e) {
      _handleAuthError(e);
      rethrow;
    }
  }

  /// Vérifier un code de réinitialisation
  Future<void> verifyResetCode(String email, String code) async {
    try {
      await _apiService.post('/check-subscribe-code', data: {
        'email': email,
        'code': code,
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Code invalide ou expiré.');
      }
      _handleAuthError(e);
      rethrow;
    }
  }

  /// Changer le mot de passe
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      // Note: Le backend ne semble pas avoir d'endpoint direct pour changer le mot de passe
      // Il faudrait soit:
      // 1. Utiliser un endpoint custom si disponible
      // 2. Implémenter côté backend
      // Pour l'instant, on simule ou on utilise une approche alternative
      throw Exception('Changement de mot de passe non encore implémenté côté API');
    } on DioException catch (e) {
      _handleAuthError(e);
      rethrow;
    }
  }

  /// Créer un compte étudiant avec tous les détails
  Future<Map<String, dynamic>> createStudentAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,  // Maintenant obligatoire
    required String university,  // Maintenant obligatoire
    required String birthDate,     // Maintenant obligatoire (format YYYY-MM-DD)
  }) async {
    try {
      print('[API] Création de compte étudiant avec:');
      print('  Email: $email');
      print('  Nom: $firstName $lastName');
      print('  Téléphone: $phoneNumber');
      print('  Université: $university');
      print('  Date de naissance: $birthDate');

      // Validation du mot de passe (nouveaux critères du backend)
      if (password.length < 8) {
        throw Exception('Le mot de passe doit contenir au moins 8 caractères.');
      }
      if (!RegExp(r'[A-Z]').hasMatch(password)) {
        throw Exception('Le mot de passe doit contenir au moins une majuscule.');
      }
      if (!RegExp(r'[a-z]').hasMatch(password)) {
        throw Exception('Le mot de passe doit contenir au moins une minuscule.');
      }
      if (!RegExp(r'[0-9]').hasMatch(password)) {
        throw Exception('Le mot de passe doit contenir au moins un chiffre.');
      }
      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
        throw Exception('Le mot de passe doit contenir au moins un caractère spécial.');
      }

      // Validation du téléphone (10 chiffres)
      if (phoneNumber.length != 10) {
        throw Exception('Le numéro de téléphone doit contenir exactement 10 chiffres.');
      }

      // Validation de la date de naissance (obligatoire et format YYYY-MM-DD)
      if (birthDate.isEmpty) {
        throw Exception('La date de naissance est obligatoire.');
      }
      final birthDateTime = DateTime.tryParse(birthDate);
      if (birthDateTime == null) {
        throw Exception('Format de date invalide. Utilisez YYYY-MM-DD.');
      }

      // Vérification de l'âge minimum (15 ans)
      final now = DateTime.now();
      final age = now.year - birthDateTime.year;
      if (now.month < birthDateTime.month || (now.month == birthDateTime.month && now.day < birthDateTime.day)) {
        if (age < 15) {
          throw Exception('Vous devez avoir au moins 15 ans pour créer un compte.');
        }
      } else {
        if (age < 15) {
          throw Exception('Vous devez avoir au moins 15 ans pour créer un compte.');
        }
      }

      // Étape 1: Créer le compte étudiant avec les champs de base
      final basicRequestData = {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      };
      
      print('[API] Étape 1: Création du compte étudiant de base');
      print('[API] Envoi de la requête à: /students');
      print('[API] Données envoyées: $basicRequestData');
      
      final createResponse = await _apiService.post('/students', data: basicRequestData);
      
      print('[API] Réponse de création: ${createResponse.statusCode}');
      print('[API] Données reçues: ${createResponse.data}');
      
      // Extraire l'ID de l'étudiant créé
      final studentId = createResponse.data['id'];
      if (studentId == null) {
        throw Exception('Impossible de récupérer l\'ID de l\'étudiant créé');
      }
      print('[API] ID de l\'étudiant créé: $studentId');
      
      // Étape 2: Se connecter pour obtenir un token JWT
      print('[API] Étape 2: Connexion pour obtenir un token JWT');
      final token = await loginWithEmailPassword(email, password);
      print('[API] Token JWT obtenu: ${token.substring(0, 20)}...');
      
      // Définir le token pour les requêtes suivantes
      _apiService.setAuthToken(token);
      
      // Conserver le token pour le retourner à la fin
      final authToken = token;
      
      // Étape 3: Mettre à jour le compte avec les informations supplémentaires
      // Selon la documentation, utiliser PATCH sur /students/{id}
      final updateData = {
        'phoneNumber': phoneNumber,
        'university': university,
        'birth_date': birthDate, // Format YYYY-MM-DD
      };
      
      print('[API] Étape 3: Mise à jour du compte avec les informations supplémentaires');
      print('[API] Envoi de la requête PATCH à: /students/$studentId');
      print('[API] Données envoyées: $updateData');
      
      // Note: Le Content-Type pour PATCH devrait être application/merge-patch+json
      // Mais cela est géré par les headers globaux
      final updateResponse = await _apiService.patch('/students/$studentId', data: updateData);
      
      print('[API] Réponse de mise à jour: ${updateResponse.statusCode}');
      print('[API] Données mises à jour: ${updateResponse.data}');
      
      // Effacer le token après la mise à jour pour ne pas interférer avec d'autres opérations
      _apiService.setAuthToken(null);
      
      // Retourner les données de l'étudiant créé et mis à jour, ainsi que le token pour connexion automatique
      return {
        'user': updateResponse.data,
        'token': authToken,
      };
    } on DioException catch (e) {
      print('[API] Erreur lors de la création du compte: ${e.message}');
      if (e.response != null) {
        print('[API] Status code: ${e.response!.statusCode}');
        print('[API] Réponse: ${e.response!.data}');
      }

      if (e.response?.statusCode == 400) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('violations')) {
          final violations = data['violations'] as List;
          if (violations.isNotEmpty) {
            final firstViolation = violations.first;
            if (firstViolation is Map && firstViolation.containsKey('message')) {
              final errorMessage = firstViolation['message'];
              print('[API] Erreur de validation: $errorMessage');
              throw Exception('Erreur de validation: $errorMessage');
            }
          }
        }
        throw Exception('Les données soumises sont invalides. Veuillez vérifier tous les champs.');
      } else if (e.response?.statusCode == 409) {
        throw Exception('Un compte existe déjà avec cet email. Veuillez vous connecter ou utiliser un autre email.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Non autorisé. Veuillez vérifier vos informations.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur. Veuillez réessayer plus tard.');
      }
      
      _handleAuthError(e);
      rethrow;
    }
  }

  void _handleAuthError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      if (statusCode == 400 && data is Map && data.containsKey('message')) {
        throw Exception(data['message']);
      } else if (statusCode == 401) {
        throw Exception('Non autorisé. Veuillez vous connecter.');
      } else if (statusCode == 403) {
        throw Exception('Accès refusé.');
      } else if (statusCode == 409) {
        throw Exception('Conflit: un compte existe déjà.');
      }
    }
    throw Exception('Erreur d\'authentification: ${e.message}');
  }

}