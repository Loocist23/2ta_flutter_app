import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/mock_user.dart';
import '../models/user.dart';
import '../services/local_storage.dart';
import '../services/api_service.dart';
import '../services/auth_api_service.dart';
import '../services/entities_api_service.dart';

enum AuthProvider { google, apple, email }

class GoogleUserData {
  const GoogleUserData({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.googleId,
    this.university,
    this.birthDate,
  });

  final String email;
  final String firstName;
  final String lastName;
  final String googleId;
  final String? university;
  final String? birthDate;
}

class AppleUserData {
  const AppleUserData({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.appleId,
    this.university,
    this.birthDate,
  });

  final String email;
  final String firstName;
  final String lastName;
  final String appleId;
  final String? university;
  final String? birthDate;
}

class StoredAccount {
  const StoredAccount({required this.user, required this.provider, this.password});

  final AppUser user;
  final AuthProvider provider;
  final String? password;

  StoredAccount copyWith({AppUser? user, AuthProvider? provider, String? password}) {
    return StoredAccount(
      user: user ?? this.user,
      provider: provider ?? this.provider,
      password: password ?? this.password,
    );
  }

  factory StoredAccount.fromJson(Map<String, dynamic> json) {
    return StoredAccount(
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      provider: AuthProvider.values.firstWhere(
        (value) => value.name == json['provider'],
        orElse: () => AuthProvider.email,
      ),
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'provider': provider.name,
        'password': password,
      };
}

class AuthController extends ChangeNotifier {
  AuthController(this._storage) {
    _hydrate();
  }

  // Initialisation lazy des services API
  ApiService _getApiService() {
    _apiService ??= ApiService();
    return _apiService!;
  }

  AuthApiService _getAuthApiService() {
    _authApiService ??= AuthApiService(_getApiService());
    return _authApiService!;
  }

  EntitiesApiService _getEntitiesApiService() {
    _entitiesApiService ??= EntitiesApiService(_getApiService());
    return _entitiesApiService!;
  }

  final LocalStorage _storage;
  ApiService? _apiService;
  AuthApiService? _authApiService;
  EntitiesApiService? _entitiesApiService;
  AppUser? _user;
  bool _hydrated = false;
  bool _loading = false;
  AuthProvider? _activeProvider;
  String? _authToken;

  static const _currentUserKey = '2ta.auth.currentUser';

  AppUser? get user => _user;
  bool get hydrated => _hydrated;
  bool get loading => _loading;
  AuthProvider? get activeProvider => _activeProvider;
  String? get authToken => _authToken;

  Future<void> _hydrate() async {
    // Charger le token d'authentification
    final storedToken = await _storage.getAuthToken();
    if (storedToken != null) {
      _authToken = storedToken;
      _getApiService().setAuthToken(storedToken);
      
      try {
        // Vérifier si le token est encore valide en récupérant l'utilisateur
        final userData = await _getAuthApiService().getCurrentUser();
        
        // Créer l'utilisateur local à partir des données API
        final newUser = await _createUserFromApiData(userData);
        
        _user = newUser;
        _activeProvider = AuthProvider.email; // Par défaut, pourrait être détecté
        
      } catch (e) {
        // Token invalide ou expiré - le supprimer
        await _storage.clearAllAuthTokens();
        _authToken = null;
        _user = null;
        print('[AUTH] Token expiré ou invalide: $e');
      }
    }

    // Charger l'utilisateur local si pas de session API valide
    if (_user == null) {
      final storedUser = await _storage.getItem(_currentUserKey);
      if (storedUser != null) {
        try {
          final parsed = AppUser.fromJson(jsonDecode(storedUser) as Map<String, dynamic>);
          _user = parsed;
          _activeProvider = AuthProvider.email; // Par défaut pour les sessions locales
        } catch (_) {
          _user = null;
        }
      }
    }

    _hydrated = true;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_loading == value) {
      return;
    }
    _loading = value;
    notifyListeners();
  }

  Future<void> _persistState() async {
    if (_user != null) {
      await _storage.setItem(_currentUserKey, jsonEncode(_user!.toJson()));
    } else {
      await _storage.removeItem(_currentUserKey);
    }
  }



  void _setUser(AppUser? user, {AuthProvider? provider}) {
    _user = user;
    if (user != null) {
      _activeProvider = provider ?? _activeProvider ?? AuthProvider.email;
    } else {
      _activeProvider = null;
    }
    notifyListeners();
    unawaited(_persistState());
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      
      // Simuler les données Google (à remplacer par l'intégration réelle Google Sign-In)
      final googleUser = await _simulateGoogleSignIn();
      
      // Appeler l'API pour obtenir le token JWT
      final token = await _getAuthApiService().loginWithGoogle(
        email: googleUser.email,
        firstName: googleUser.firstName,
        lastName: googleUser.lastName,
        googleId: googleUser.googleId,
        university: googleUser.university,
        birthDate: googleUser.birthDate,
      );
      
      // Sauvegarder le token
      await _storage.saveAuthToken(token);
      _authToken = token;
      _getApiService().setAuthToken(token);
      
      // Récupérer les informations utilisateur
      final userData = await _getAuthApiService().getCurrentUser();
      
      // Créer l'utilisateur local avec les données réelles
      final newUser = await _createUserFromApiData(userData);
      
      _setUser(newUser, provider: AuthProvider.google);
      
    } catch (error) {
      _setLoading(false);
      rethrow;
    }
  }

  /// Simule les données Google (à remplacer par l'intégration réelle)
  Future<GoogleUserData> _simulateGoogleSignIn() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return GoogleUserData(
      email: 'camille.martin@example.com',
      firstName: 'Camille',
      lastName: 'Martin',
      googleId: 'google-${DateTime.now().millisecondsSinceEpoch}',
      university: 'Université de Paris',
      birthDate: '2000-01-01',
    );
  }

  Future<void> signInWithApple() async {
    try {
      _setLoading(true);
      
      // Simuler les données Apple (à remplacer par l'intégration réelle Apple Sign-In)
      final appleUser = await _simulateAppleSignIn();
      
      // Appeler l'API pour obtenir le token JWT
      final token = await _getAuthApiService().loginWithApple(
        email: appleUser.email,
        firstName: appleUser.firstName,
        lastName: appleUser.lastName,
        appleId: appleUser.appleId,
        university: appleUser.university,
        birthDate: appleUser.birthDate,
      );
      
      // Sauvegarder le token
      await _storage.saveAuthToken(token);
      _authToken = token;
      _getApiService().setAuthToken(token);
      
      // Récupérer les informations utilisateur
      final userData = await _getAuthApiService().getCurrentUser();
      
      // Créer l'utilisateur local avec les données réelles
      final newUser = await _createUserFromApiData(userData);
      
      _setUser(newUser, provider: AuthProvider.apple);
      
    } catch (error) {
      _setLoading(false);
      rethrow;
    }
  }

  /// Simule les données Apple (à remplacer par l'intégration réelle)
  Future<AppleUserData> _simulateAppleSignIn() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return AppleUserData(
      email: 'camille.martin@icloud.com',
      firstName: 'Camille',
      lastName: 'Martin',
      appleId: 'apple-${DateTime.now().millisecondsSinceEpoch}',
      university: 'Université de Paris',
      birthDate: '2000-01-01',
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    if (normalizedEmail.isEmpty) {
      throw Exception('Veuillez renseigner une adresse email.');
    }

    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(normalizedEmail)) {
      throw Exception("L'adresse email n'est pas valide.");
    }

    if (password.trim().length < 6) {
      throw Exception('Le mot de passe doit contenir au moins 6 caractères.');
    }

    try {
      _setLoading(true);
      
      // Appeler l'API pour obtenir le token JWT
      final token = await _getAuthApiService().loginWithEmailPassword(normalizedEmail, password);
      
      // Sauvegarder le token
      await _storage.saveAuthToken(token);
      _authToken = token;
      _getApiService().setAuthToken(token);
      
      // Récupérer les informations utilisateur
      final userData = await _getAuthApiService().getCurrentUser();
      
      // Créer l'utilisateur local avec les données réelles
      final newUser = await _createUserFromApiData(userData);
      
      _setUser(newUser, provider: AuthProvider.email);
      
    } catch (error) {
      _setLoading(false);
      rethrow;
    }
  }

  /// Inscription avec tous les détails (flow multi-étapes)
  Future<void> signUpWithDetails({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String university,
    required DateTime birthDate,
  }) async {
    try {
      print('[AUTH] Début de l\'inscription avec les détails:');
      print('  Email: $email');
      print('  Nom: $firstName $lastName');
      print('  Téléphone: $phone');
      print('  Université: $university');
      print('  Date de naissance: $birthDate');

      _setLoading(true);

      // Étape 1: Créer le compte étudiant
      print('[AUTH] Appel à createStudentAccount...');
      // Formater la date en YYYY-MM-DD
      final formattedBirthDate = '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
      
      // createStudentAccount retourne maintenant un map avec 'user' et 'token'
      final result = await _getAuthApiService().createStudentAccount(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phone,
        university: university,
        birthDate: formattedBirthDate,
      );
      
      print('[AUTH] Compte étudiant créé avec succès');
      
      // Récupérer le token de connexion automatique
      final token = result['token'] as String;
      print('[AUTH] Token reçu via création de compte: ${token.substring(0, 20)}...');
      
      // Sauvegarder le token
      await _storage.saveAuthToken(token);
      _authToken = token;
      _getApiService().setAuthToken(token);
      print('[AUTH] Token sauvegardé');
      
      // Étape 3: Récupérer les informations utilisateur
      print('[AUTH] Récupération des données utilisateur...');
      final userData = await _getAuthApiService().getCurrentUser();
      print('[AUTH] Données utilisateur reçues: ${userData['email']}');
      
      // Créer l'utilisateur local avec les données réelles
      final newUser = await _createUserFromApiData(userData);
      
      _setUser(newUser, provider: AuthProvider.email);
      print('[AUTH] Utilisateur connecté avec succès !');
      
    } catch (error) {
      print('[AUTH] Erreur lors de l\'inscription: $error');
      _setLoading(false);
      
      // Ajouter plus de détails sur l'erreur
      if (error is Exception) {
        final errorMessage = error.toString();
        print('[AUTH] Détails de l\'erreur: $errorMessage');
        
        // Ré-throw avec un message plus détaillé
        if (errorMessage.contains('400')) {
          throw Exception('Erreur de validation des données. Veuillez vérifier toutes les informations saisies.');
        } else if (errorMessage.contains('409')) {
          throw Exception('Un compte existe déjà avec cet email. Veuillez vous connecter.');
        } else if (errorMessage.contains('401')) {
          throw Exception('Échec de la connexion automatique. Veuillez essayer de vous connecter manuellement.');
        } else if (errorMessage.contains('500')) {
          throw Exception('Erreur serveur. Veuillez réessayer plus tard ou contacter le support.');
        } else if (errorMessage.contains('timeout')) {
          throw Exception('Connexion au serveur impossible. Veuillez vérifier votre connexion internet.');
        }
      }
      
      rethrow;
    }
  }

  Future<void> requestPasswordReset(String email) async {
    final normalizedEmail = _normalizeEmail(email);

    if (normalizedEmail.isEmpty) {
      throw Exception('Veuillez renseigner votre adresse email.');
    }

    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(normalizedEmail)) {
      throw Exception("L'adresse email n'est pas valide.");
    }

    await _getAuthApiService().requestPasswordReset(normalizedEmail);
  }

  Future<void> updatePassword({String? currentPassword, required String newPassword}) async {
    final currentUser = _user;
    if (currentUser == null) {
      throw Exception('Vous devez être connecté pour modifier votre mot de passe.');
    }

    if (newPassword.trim().length < 8) {
      throw Exception('Le nouveau mot de passe doit contenir au moins 8 caractères.');
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(newPassword) ||
        !RegExp(r'[0-9]').hasMatch(newPassword)) {
      throw Exception('Le mot de passe doit contenir au moins une lettre et un chiffre.');
    }

    try {
      await _getAuthApiService().changePassword(currentPassword ?? '', newPassword);
      
      // Mettre à jour l'utilisateur local
      final nextUser = currentUser.copyWith(hasPassword: true);
      _setUser(nextUser, provider: _activeProvider ?? AuthProvider.email);
      
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _storage.clearAllAuthTokens();
    _authToken = null;
    if (_apiService != null) {
      _apiService!.clearAuthToken();
    }
    _setUser(null);
  }

  /// Méthode pour gérer la déconnexion automatique en cas de token expiré
  Future<void> handleTokenExpired() async {
    print('[AUTH] Déconnexion automatique due à un token expiré');
    await signOut();
  }

  Future<void> deleteAccount() async {
    await signOut(); // Déconnexion complète
  }

  void _updateUser(AppUser Function(AppUser user) updater) {
    final current = _user;
    if (current == null) {
      return;
    }
    final nextUser = updater(current);
    _user = nextUser;
    notifyListeners();
    unawaited(_persistState());
  }

  void toggleFavorite(String jobId) {
    _updateUser((user) {
      final favorites = List<String>.from(user.favorites);
      if (favorites.contains(jobId)) {
        favorites.remove(jobId);
      } else {
        favorites.add(jobId);
      }
      return user.copyWith(favorites: favorites);
    });
  }

  void markNotificationRead(String notificationId) {
    _updateUser((user) {
      final notifications = user.notifications
          .map((item) =>
              item.id == notificationId ? item.copyWith(read: true) : item)
          .toList();
      return user.copyWith(notifications: notifications);
    });
  }

  void markAllNotificationsRead() {
    _updateUser((user) {
      final notifications =
          user.notifications.map((item) => item.copyWith(read: true)).toList();
      return user.copyWith(notifications: notifications);
    });
  }

  void removeNotification(String notificationId) {
    _updateUser((user) {
      final notifications =
          user.notifications.where((item) => item.id != notificationId).toList();
      return user.copyWith(notifications: notifications);
    });
  }

  void toggleAlertActivation(String alertId) {
    _updateUser((user) {
      final alerts = user.alerts
          .map((alert) => alert.id == alertId
              ? alert.copyWith(active: !alert.active)
              : alert)
          .toList();
      return user.copyWith(alerts: alerts);
    });
  }

  void updateSettings({
    bool? pushNotifications,
    bool? emailSubscriptions,
    CookieConsent? cookieConsent,
    bool? accessibilityMode,
  }) {
    _updateUser((user) {
      final settings = user.settings.copyWith(
        pushNotifications: pushNotifications,
        emailSubscriptions: emailSubscriptions,
        cookieConsent: cookieConsent,
        accessibilityMode: accessibilityMode,
      );
      return user.copyWith(settings: settings);
    });
  }

  void updateProfile({
    String? name,
    String? title,
    String? location,
    String? phone,
    String? bio,
  }) {
    _updateUser((user) {
      final normalizedName = name?.trim();
      final normalizedTitle = title?.trim();
      final normalizedLocation = location?.trim();
      final normalizedPhone = phone?.trim();
      final normalizedBio = bio?.trim();

      return user.copyWith(
        name: normalizedName?.isNotEmpty == true ? normalizedName : user.name,
        title: normalizedTitle?.isNotEmpty == true
            ? normalizedTitle
            : user.title,
        location: normalizedLocation?.isNotEmpty == true
            ? normalizedLocation
            : user.location,
        phone: phone == null
            ? user.phone
            : (normalizedPhone?.isNotEmpty == true ? normalizedPhone : null),
        bio: bio == null
            ? user.bio
            : (normalizedBio?.isNotEmpty == true ? normalizedBio : null),
        avatarInitials: normalizedName?.isNotEmpty == true
            ? extractInitials(normalizedName!)
            : user.avatarInitials,
      );
    });
  }

  void addCv(String name) {
    _updateUser((user) {
      final nextCv = UserCv(
        id: 'cv-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        updatedAt: 'Ajouté à l’instant',
        isPrimary: user.cvs.isEmpty,
      );
      return user.copyWith(cvs: [...user.cvs, nextCv]);
    });
  }

  void renameCv(String id, String name) {
    _updateUser((user) {
      final cvs = user.cvs
          .map((cv) =>
              cv.id == id ? cv.copyWith(name: name, updatedAt: 'Mis à jour à l’instant') : cv)
          .toList();
      return user.copyWith(cvs: cvs);
    });
  }

  void removeCv(String id) {
    _updateUser((user) {
      final remaining = user.cvs.where((cv) => cv.id != id).toList();
      if (remaining.isEmpty) {
        return user.copyWith(cvs: remaining);
      }
      final normalized = remaining
          .asMap()
          .entries
          .map((entry) =>
              entry.value.copyWith(isPrimary: entry.key == 0))
          .toList();
      return user.copyWith(cvs: normalized);
    });
  }

  void setPrimaryCv(String id) {
    _updateUser((user) {
      final cvs = user.cvs
          .map((cv) => cv.copyWith(isPrimary: cv.id == id))
          .toList();
      return user.copyWith(cvs: cvs);
    });
  }

  String createAlert({
    required String title,
    required List<String> keywords,
    required String location,
    required AlertFrequency frequency,
    bool active = true,
  }) {
    final id = 'alert-${DateTime.now().millisecondsSinceEpoch}';
    final alert = UserAlert(
      id: id,
      title: title,
      keywords: keywords,
      location: location,
      frequency: frequency,
      lastRun: 'Jamais',
      active: active,
    );
    _updateUser((user) => user.copyWith(alerts: [...user.alerts, alert]));
    return id;
  }

  void updateAlert(
    String alertId, {
    String? title,
    List<String>? keywords,
    String? location,
    AlertFrequency? frequency,
    bool? active,
    String? lastRun,
  }) {
    _updateUser((user) {
      final alerts = user.alerts
          .map((alert) => alert.id == alertId
              ? alert.copyWith(
                  title: title ?? alert.title,
                  keywords: keywords ?? alert.keywords,
                  location: location ?? alert.location,
                  frequency: frequency ?? alert.frequency,
                  active: active ?? alert.active,
                  lastRun: lastRun ?? alert.lastRun,
                )
              : alert)
          .toList();
      return user.copyWith(alerts: alerts);
    });
  }

  void deleteAlert(String alertId) {
    _updateUser((user) {
      final alerts = user.alerts.where((alert) => alert.id != alertId).toList();
      return user.copyWith(alerts: alerts);
    });
  }

  int _applicationsInProgress(List<UserApplication> applications) {
    return applications
        .where((application) => application.status != ApplicationStatus.offer)
        .length;
  }

  void addApplication({
    required String jobId,
    required String company,
    required String title,
    required ApplicationStatus status,
    required String appliedOn,
    String? lastUpdate,
    String? nextStep,
    List<String>? notes,
  }) {
    _updateUser((user) {
      final application = UserApplication(
        id: 'application-${DateTime.now().millisecondsSinceEpoch}',
        jobId: jobId,
        company: company,
        title: title,
        status: status,
        lastUpdate: lastUpdate ?? 'Ajoutée à l’instant',
        nextStep: nextStep,
        appliedOn: appliedOn,
        notes: notes ?? const [],
      );
      final applications = [application, ...user.applications];
      final stats = user.stats.copyWith(
        applicationsInProgress: _applicationsInProgress(applications),
      );
      return user.copyWith(applications: applications, stats: stats);
    });
  }

  void updateApplication(
    String applicationId, {
    ApplicationStatus? status,
    String? lastUpdate,
    String? nextStep,
    List<String>? notes,
  }) {
    _updateUser((user) {
      final applications = user.applications.map((application) {
        if (application.id != applicationId) {
          return application;
        }
        return application.copyWith(
          status: status ?? application.status,
          lastUpdate: lastUpdate ?? application.lastUpdate,
          nextStep: nextStep ?? application.nextStep,
          notes: notes ?? application.notes,
        );
      }).toList();
      final stats = user.stats.copyWith(
        applicationsInProgress: _applicationsInProgress(applications),
      );
      return user.copyWith(applications: applications, stats: stats);
    });
  }

  void addApplicationNote(String applicationId, String note) {
    _updateUser((user) {
      final applications = user.applications.map((application) {
        if (application.id != applicationId) {
          return application;
        }
        final notes = [...application.notes, note];
        return application.copyWith(
          notes: notes,
          lastUpdate: 'Note ajoutée à l’instant',
        );
      }).toList();
      return user.copyWith(applications: applications);
    });
  }

  void updateApplicationStatus(
    String applicationId,
    ApplicationStatus status, {
    String? nextStep,
  }) {
    _updateUser((user) {
      final applications = user.applications.map((application) {
        if (application.id != applicationId) {
          return application;
        }
        return application.copyWith(
          status: status,
          nextStep: nextStep ?? application.nextStep,
          lastUpdate: 'Statut mis à jour à l’instant',
        );
      }).toList();
      final stats = user.stats.copyWith(
        applicationsInProgress: _applicationsInProgress(applications),
      );
      return user.copyWith(applications: applications, stats: stats);
    });
  }

  void followCompany(String companyId) {
    _updateUser((user) {
      if (user.followedCompanies.contains(companyId)) {
        return user;
      }
      return user.copyWith(
        followedCompanies: [...user.followedCompanies, companyId],
      );
    });
  }

  void unfollowCompany(String companyId) {
    _updateUser((user) {
      final companies =
          user.followedCompanies.where((id) => id != companyId).toList();
      return user.copyWith(followedCompanies: companies);
    });
  }

  /// Create user from real API data including applications
  Future<AppUser> _createUserFromApiData(Map<String, dynamic> userData) async {
    try {
      // Get user applications from API
      final applicationsResult = await _getEntitiesApiService().getUserApplications(userData['id'] ?? '');
      final apiApplications = applicationsResult['applications'] as List? ?? [];
      
      // Map API applications to our model
      final userApplications = apiApplications.map((app) {
        final offerId = (app['offer'] as String?)?.split('/').last ?? 'unknown';
        final companyName = app['offer']?['company']?['name'] ?? 'Unknown Company';
        final jobTitle = app['offer']?['title'] ?? 'Unknown Job';
        
        return UserApplication(
          id: app['id'] ?? 'app-${DateTime.now().millisecondsSinceEpoch}',
          jobId: offerId,
          company: companyName,
          title: jobTitle,
          status: _mapApiStatusToLocal(app['status']),
          lastUpdate: app['updatedAt'] != null ? 'Updated ${_formatDate(app['updatedAt'])}' : 'No updates',
          appliedOn: app['createdAt'] != null ? 'Applied on ${_formatDate(app['createdAt'])}' : 'Date unknown',
          notes: [], // Notes would need to be stored locally
        );
      }).toList();

      // Create user with applications
      final newUser = cloneUser(mockUser).copyWith(
        id: userData['id'] ?? 'restored-${DateTime.now().millisecondsSinceEpoch}',
        email: userData['email'] ?? '',
        name: '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}',
        avatarInitials: extractInitials('${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'),
        hasPassword: userData['isPasswordSet'] ?? false,
        applications: userApplications,
      );
      return newUser;
    } catch (e) {
      print('[AUTH] Error loading user data from API: $e');
      // Fallback to basic user creation
      return createDefaultUser(
        id: userData['id'] ?? 'restored-${DateTime.now().millisecondsSinceEpoch}',
        email: userData['email'] ?? '',
        name: '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}',
        avatarInitials: extractInitials('${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'),
        hasPassword: userData['isPasswordSet'] ?? false,
      );
    }
  }

  ApplicationStatus _mapApiStatusToLocal(String? apiStatus) {
    switch (apiStatus?.toUpperCase()) {
      case 'WAITING': return ApplicationStatus.sent;
      case 'ACCEPTED': return ApplicationStatus.interview;
      case 'REJECTED': return ApplicationStatus.rejected;
      default: return ApplicationStatus.sent;
    }
  }

  String _formatDate(dynamic dateData) {
    try {
      if (dateData is String) {
        return dateData.split('T').first;
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }
}
