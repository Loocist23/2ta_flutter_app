class JobOffer {
  const JobOffer({
    required this.id,
    required this.title,
    required this.company,
    this.companyId,
    required this.location,
    required this.contract,
    required this.salary,
    required this.postedAt,
    required this.remoteType,
    required this.tags,
    required this.description,
  });

  final String id;
  final String title;
  final String company;
  final String? companyId;
  final String location;
  final String contract;
  final String salary;
  final String postedAt;
  final String remoteType;
  final List<String> tags;
  final String description;

  factory JobOffer.fromJson(Map<String, dynamic> json) {
    return JobOffer(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      companyId: json['companyId'] as String?,
      location: json['location'] as String,
      contract: json['contract'] as String,
      salary: json['salary'] as String,
      postedAt: json['postedAt'] as String,
      remoteType: json['remoteType'] as String,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'companyId': companyId,
      'location': location,
      'contract': contract,
      'salary': salary,
      'postedAt': postedAt,
      'remoteType': remoteType,
      'tags': tags,
      'description': description,
    };
  }
}
