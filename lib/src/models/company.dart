class Company {
  const Company({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.industry,
    required this.employees,
    required this.website,
    required this.culture,
    required this.openRoles,
  });

  final String id;
  final String name;
  final String location;
  final String description;
  final String industry;
  final String employees;
  final String website;
  final List<String> culture;
  final int openRoles;

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      industry: json['industry'] as String,
      employees: json['employees'] as String,
      website: json['website'] as String,
      culture: (json['culture'] as List<dynamic>).cast<String>(),
      openRoles: json['openRoles'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'industry': industry,
      'employees': employees,
      'website': website,
      'culture': culture,
      'openRoles': openRoles,
    };
  }
}
