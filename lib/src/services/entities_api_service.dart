import 'package:dio/dio.dart';

import 'api_service.dart';

class EntitiesApiService {
  final ApiService _apiService;

  EntitiesApiService(this._apiService);

  // =======================
  // Offers (Offres d'alternance)
  // =======================

  /// Get all offers with optional filtering
  Future<Map<String, dynamic>> getOffers({
    int page = 1,
    int itemsPerPage = 30,
    String? title,
    String? status,
    String? romeId,
    String? companyId,
    List<String>? contractTypes,
    String? remote,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'itemsPerPage': itemsPerPage,
        if (title != null && title.isNotEmpty) 'title': title,
        if (status != null && status.isNotEmpty) 'status': status,
        if (romeId != null && romeId.isNotEmpty) 'rome.id': romeId,
        if (companyId != null && companyId.isNotEmpty) 'company.id': companyId,
        if (contractTypes != null && contractTypes.isNotEmpty) 'contractType[]': contractTypes,
        if (remote != null && remote.isNotEmpty) 'remote': remote,
      };

      final response = await _apiService.get('/offers', queryParameters: queryParameters);
      
      // Extract the hydra:member array and total count
      final data = response.data as Map<String, dynamic>;
      final offers = data['hydra:member'] ?? [];
      final totalItems = data['hydra:totalItems'] ?? 0;
      
      return {
        'offers': offers,
        'totalItems': totalItems,
        'pagination': data['hydra:view'] ?? {},
      };
    } on DioException catch (e) {
      _handleApiError(e);
      rethrow;
    }
  }

  /// Get a specific offer by ID
  Future<Map<String, dynamic>> getOffer(String offerId) async {
    try {
      final response = await _apiService.get('/offers/$offerId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleApiError(e);
      rethrow;
    }
  }

  /// Create a new offer (for companies)
  Future<Map<String, dynamic>> createOffer({
    required String rome,
    required DateTime contractStart,
    required int contractDuration,
    required List<String> contractType,
    String? remote,
    String? applyUrl,
    String? applyPhone,
    required String title,
    required String description,
    String? targetDiploma,
    List<String>? desiredSkills,
    List<String>? toBeAcquiredSkills,
    required String company,
  }) async {
    try {
      final response = await _apiService.post('/offers', data: {
        'rome': rome,
        'contractStart': contractStart.toIso8601String(),
        'contractDuration': contractDuration,
        'contractType': contractType,
        if (remote != null) 'remote': remote,
        if (applyUrl != null) 'applyUrl': applyUrl,
        if (applyPhone != null) 'applyPhone': applyPhone,
        'title': title,
        'description': description,
        if (targetDiploma != null) 'targetDiploma': targetDiploma,
        if (desiredSkills != null) 'desiredSkills': desiredSkills,
        if (toBeAcquiredSkills != null) 'toBeAcquiredSkills': toBeAcquiredSkills,
        'company': company,
      });

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleApiError(e);
      rethrow;
    }
  }

  // =======================
  // Applications (Candidatures)
  // =======================

  /// Get all applications with optional filtering
  Future<Map<String, dynamic>> getApplications({
    int page = 1,
    int itemsPerPage = 30,
    String? offerId,
    String? studentId,
    String? status,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'itemsPerPage': itemsPerPage,
        if (offerId != null && offerId.isNotEmpty) 'offer.id': offerId,
        if (studentId != null && studentId.isNotEmpty) 'student.id': studentId,
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final response = await _apiService.get('/applications', queryParameters: queryParameters);
      
      // Extract the hydra:member array and total count
      final data = response.data as Map<String, dynamic>;
      final applications = data['hydra:member'] ?? [];
      final totalItems = data['hydra:totalItems'] ?? 0;
      
      return {
        'applications': applications,
        'totalItems': totalItems,
        'pagination': data['hydra:view'] ?? {},
      };
    } on DioException catch (e) {
      _handleApiError(e);
      rethrow;
    }
  }

  /// Get applications for current user
  Future<Map<String, dynamic>> getUserApplications(String userId) async {
    return getApplications(studentId: userId, itemsPerPage: 100);
  }

  /// Get a specific application by ID
  Future<Map<String, dynamic>> getApplication(String applicationId) async {
    try {
      final response = await _apiService.get('/applications/$applicationId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleApiError(e);
      rethrow;
    }
  }

  /// Create a new application
  Future<Map<String, dynamic>> createApplication({
    required String message,
    String? cv,
    String? status,
    required String offer,
    required String student,
  }) async {
    try {
      final response = await _apiService.post('/applications', data: {
        'message': message,
        if (cv != null) 'cv': cv,
        if (status != null) 'status': status,
        'offer': offer,
        'student': student,
      });

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleApiError(e);
      rethrow;
    }
  }

  // =======================
  // Companies (Entreprises)
  // =======================

  /// Get all companies with optional filtering
  Future<Map<String, dynamic>> getCompanies({
    int page = 1,
    int itemsPerPage = 30,
    String? name,
    String? siret,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'itemsPerPage': itemsPerPage,
        if (name != null && name.isNotEmpty) 'name': name,
        if (siret != null && siret.isNotEmpty) 'siret': siret,
      };

      final response = await _apiService.get('/companies', queryParameters: queryParameters);
      
      // Extract the hydra:member array and total count
      final data = response.data as Map<String, dynamic>;
      final companies = data['hydra:member'] ?? [];
      final totalItems = data['hydra:totalItems'] ?? 0;
      
      return {
        'companies': companies,
        'totalItems': totalItems,
        'pagination': data['hydra:view'] ?? {},
      };
    } on DioException catch (e) {
      _handleApiError(e);
      rethrow;
    }
  }

  /// Get a specific company by ID
  Future<Map<String, dynamic>> getCompany(String companyId) async {
    try {
      final response = await _apiService.get('/companies/$companyId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleApiError(e);
      rethrow;
    }
  }

  /// Create a new company
  Future<Map<String, dynamic>> createCompany({
    required String email,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required String siret,
    required String name,
    String? logo,
  }) async {
    try {
      final response = await _apiService.post('/companies', data: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'siret': siret,
        'name': name,
        if (logo != null) 'logo': logo,
      });

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleApiError(e);
      rethrow;
    }
  }

  // =======================
  // Rome (Métiers)
  // =======================

  /// Get all ROME codes with optional filtering
  Future<Map<String, dynamic>> getRomes({
    int page = 1,
    int itemsPerPage = 30,
    List<String>? codes,
    String? label,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'itemsPerPage': itemsPerPage,
        if (codes != null && codes.isNotEmpty) 'code[]': codes,
        if (label != null && label.isNotEmpty) 'label': label,
      };

      final response = await _apiService.get('/romes', queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleApiError(e);
      rethrow;
    }
  }

  /// Get a specific ROME by ID
  Future<Map<String, dynamic>> getRome(String romeId) async {
    try {
      final response = await _apiService.get('/romes/$romeId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleApiError(e);
      rethrow;
    }
  }

  // =======================
  // Users
  // =======================

  /// Get current user information
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiService.get('/me');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Non autorisé. Veuillez vous reconnecter.');
      }
      _handleApiError(e);
      rethrow;
    }
  }

  /// Get user by ID (admin only)
  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleApiError(e);
      rethrow;
    }
  }

  // =======================
  // Error Handling
  // =======================

  void _handleApiError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      if (statusCode == 400 && data is Map && data.containsKey('message')) {
        throw Exception(data['message']);
      } else if (statusCode == 401) {
        throw Exception('Non autorisé. Veuillez vous connecter.');
      } else if (statusCode == 403) {
        throw Exception('Accès refusé.');
      } else if (statusCode == 404) {
        throw Exception('Ressource non trouvée.');
      } else if (statusCode == 409) {
        throw Exception('Conflit: la ressource existe déjà.');
      } else if (statusCode == 500) {
        throw Exception('Erreur serveur. Veuillez réessayer plus tard.');
      }
    }
    throw Exception('Erreur API: ${e.message}');
  }
}