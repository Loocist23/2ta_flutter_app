import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  String? _authToken;

  // URL de l'API de production
  static const String _apiBaseUrl = 'https://api.trouvetonalternance.eu';
  
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: _apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/ld+json',
      'Accept': 'application/ld+json',
    },
  )) {
    _setupInterceptors();
    print('[API] Service initialisé avec URL: $_apiBaseUrl');
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        _handleDioError(e);
        return handler.next(e);
      },
    ));
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      // Pour les requêtes PATCH, utiliser application/merge-patch+json comme requis par l'API
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: {'Content-Type': 'application/merge-patch+json'},
        ),
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    print('[API] Erreur Dio détaillée:');
    print('  Type: ${e.type}');
    print('  Message: ${e.message}');
    print('  URI: ${e.requestOptions.uri}');
    print('  Méthode: ${e.requestOptions.method}');
    
    if (e.response != null) {
      print('  Status: ${e.response!.statusCode}');
      print('  Data: ${e.response!.data}');
      print('  Headers: ${e.response!.headers}');

      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      String errorMessage = 'Une erreur est survenue';

      if (data is Map && data.containsKey('message')) {
        errorMessage = data['message'];
      } else if (data is Map && data.containsKey('hydra:description')) {
        errorMessage = data['hydra:description'];
      } else if (statusCode == 200) {
        errorMessage = 'Requête réussie';
      } else if (statusCode == 201) {
        errorMessage = 'Ressource créée';
      } else if (statusCode == 204) {
        errorMessage = 'Suppression réussie';
      } else if (statusCode == 400) {
        errorMessage = 'Paramètres manquants ou invalides';
      } else if (statusCode == 401) {
        errorMessage = 'Authentification requise ou échouée';
      } else if (statusCode == 403) {
        errorMessage = 'Accès refusé (rôle insuffisant)';
      } else if (statusCode == 404) {
        errorMessage = 'Ressource non trouvée';
      } else if (statusCode == 409) {
        errorMessage = 'Conflit (ex: email déjà utilisé)';
      } else if (statusCode == 500) {
        errorMessage = 'Erreur serveur';
      }

      throw Exception(errorMessage);
    } else if (e.type == DioExceptionType.connectionTimeout ||
               e.type == DioExceptionType.receiveTimeout) {
      throw Exception('Timeout de connexion. Veuillez vérifier votre connexion internet.');
    } else if (e.type == DioExceptionType.badResponse) {
      throw Exception('Réponse invalide du serveur.');
    } else if (e.type == DioExceptionType.badCertificate) {
      throw Exception('Problème de certificat SSL. Le certificat du serveur n\'est pas valide.');
    } else if (e.type == DioExceptionType.connectionError) {
      throw Exception('Impossible de se connecter au serveur. Vérifiez votre connexion ou l\'URL de l\'API.');
    } else {
      throw Exception('Erreur réseau: ${e.message}. Type: ${e.type}');
    }
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
  }
}