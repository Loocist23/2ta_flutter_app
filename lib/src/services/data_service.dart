import 'package:flutter/foundation.dart';

import '../models/job_offer.dart';
import '../models/company.dart';
import 'entities_api_service.dart';

class DataService with ChangeNotifier {
  final EntitiesApiService _apiService;
  
  DataService(this._apiService);
  
  List<JobOffer> _jobOffers = [];
  bool _loadingJobs = false;
  String? _jobsError;
  
  List<Company> _companies = [];
  bool _loadingCompanies = false;
  String? _companiesError;
  
  // Getters
  List<JobOffer> get jobOffers => _jobOffers;
  bool get loadingJobs => _loadingJobs;
  String? get jobsError => _jobsError;
  
  List<Company> get companies => _companies;
  bool get loadingCompanies => _loadingCompanies;
  String? get companiesError => _companiesError;
  
  /// Load job offers from API
  Future<void> loadJobOffers({int page = 1, int itemsPerPage = 50}) async {
    if (_loadingJobs) return;
    
    _loadingJobs = true;
    _jobsError = null;
    notifyListeners();
    
    try {
      final result = await _apiService.getOffers(
        page: page,
        itemsPerPage: itemsPerPage,
        status: 'ACTIVE',
      );
      
      final offers = result['offers'] as List? ?? [];
      _jobOffers = offers.map((offer) => _mapApiOfferToModel(offer)).toList();
      
    } catch (e) {
      _jobsError = 'Failed to load job offers: ${e.toString()}';
      debugPrint('[DATA] Error loading job offers: $e');
      // Fallback to empty list on error
      _jobOffers = [];
    } finally {
      _loadingJobs = false;
      notifyListeners();
    }
  }
  
  /// Load companies from API
  Future<void> loadCompanies({int page = 1, int itemsPerPage = 50}) async {
    if (_loadingCompanies) return;
    
    _loadingCompanies = true;
    _companiesError = null;
    notifyListeners();
    
    try {
      final result = await _apiService.getCompanies(
        page: page,
        itemsPerPage: itemsPerPage,
      );
      
      final companies = result['companies'] as List? ?? [];
      _companies = companies.map((company) => _mapApiCompanyToModel(company)).toList();
      
    } catch (e) {
      _companiesError = 'Failed to load companies: ${e.toString()}';
      debugPrint('[DATA] Error loading companies: $e');
      // Fallback to empty list on error
      _companies = [];
    } finally {
      _loadingCompanies = false;
      notifyListeners();
    }
  }
  
  /// Map API offer data to our JobOffer model
  JobOffer _mapApiOfferToModel(Map<String, dynamic> apiOffer) {
    final company = apiOffer['company'] as Map<String, dynamic>?;
    
    return JobOffer(
      id: apiOffer['id']?.toString() ?? 'offer-${apiOffer['@id']?.hashCode}',
      title: apiOffer['title'] ?? 'Untitled Position',
      company: company?['name'] ?? 'Unknown Company',
      companyId: company?['id']?.toString() ?? 'unknown',
      location: _extractLocation(apiOffer),
      contract: _mapContractTypes(apiOffer['contractType']),
      salary: _extractSalary(apiOffer),
      postedAt: 'Published ${_formatDate(apiOffer['publishedAt'])}',
      remoteType: _mapRemoteType(apiOffer['remote']),
      tags: _extractTags(apiOffer),
      description: apiOffer['description'] ?? 'No description available',
    );
  }
  
  String _extractLocation(Map<String, dynamic> apiOffer) {
    // Try to extract location from various fields
    if (apiOffer['remote'] == 'full') {
      return 'Télétravail';
    }
    
    // Check if company has location data (not in current API, but future-proof)
    final company = apiOffer['company'] as Map<String, dynamic>?;
    if (company != null && company['location'] != null) {
      return company['location'];
    }
    
    return 'Location not specified';
  }
  
  String _mapContractTypes(dynamic contractTypes) {
    if (contractTypes is List && contractTypes.isNotEmpty) {
      return contractTypes.map((t) => t.toString().capitalize()).join(' / ');
    }
    return 'Contract type not specified';
  }
  
  String _extractSalary(Map<String, dynamic> apiOffer) {
    // Salary is not in the current API response, but we can add a placeholder
    return 'Salary not specified';
  }
  
  String _mapRemoteType(dynamic remote) {
    if (remote == null) return 'Présentiel';
    
    switch (remote.toString().toLowerCase()) {
      case 'full': return 'Télétravail';
      case 'partiel': return 'Hybride';
      case 'no': return 'Présentiel';
      default: return remote.toString().capitalize();
    }
  }
  
  List<String> _extractTags(Map<String, dynamic> apiOffer) {
    final tags = <String>[];
    
    // Add skills if available
    if (apiOffer['desiredSkills'] is List) {
      tags.addAll((apiOffer['desiredSkills'] as List).map((s) => s.toString()));
    }
    
    // Add contract types as tags
    if (apiOffer['contractType'] is List) {
      tags.addAll((apiOffer['contractType'] as List).map((s) => s.toString().capitalize()));
    }
    
    // Add ROME code if available
    final rome = apiOffer['rome'] as Map<String, dynamic>?;
    if (rome != null && rome['code'] is List && (rome['code'] as List).isNotEmpty) {
      tags.add((rome['code'] as List).first.toString());
    }
    
    return tags.take(5).toList(); // Limit to 5 tags
  }
  
  /// Map API company data to our Company model
  Company _mapApiCompanyToModel(Map<String, dynamic> apiCompany) {
    return Company(
      id: apiCompany['id']?.toString() ?? 'company-${apiCompany['@id']?.hashCode}',
      name: apiCompany['name'] ?? 'Unknown Company',
      location: apiCompany['location'] ?? 'Location not specified',
      description: apiCompany['description'] ?? 'No description available',
      industry: apiCompany['industry'] ?? 'Industry not specified',
      employees: apiCompany['employees'] ?? 'Size not specified',
      website: apiCompany['website'] ?? '',
      culture: apiCompany['culture'] is List
          ? List<String>.from(apiCompany['culture'])
          : [],
      openRoles: apiCompany['openRoles'] ?? 0,
    );
  }
  
  String _formatDate(dynamic dateData) {
    try {
      if (dateData is String) {
        return dateData.split('T').first;
      }
      return 'Unknown date';
    } catch (e) {
      return 'Unknown date';
    }
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}