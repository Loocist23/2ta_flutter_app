import 'dart:convert';

enum NotificationType { application, alert, information }

enum NotificationLinkType { job, application, alert }

class NotificationLink {
  const NotificationLink({required this.type, required this.targetId});

  final NotificationLinkType type;
  final String targetId;

  factory NotificationLink.fromJson(Map<String, dynamic> json) {
    return NotificationLink(
      type: NotificationLinkType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => NotificationLinkType.job,
      ),
      targetId: json['targetId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'targetId': targetId,
      };
}

class UserNotification {
  const UserNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    required this.read,
    this.link,
  });

  final String id;
  final String title;
  final String message;
  final String date;
  final NotificationType type;
  final bool read;
  final NotificationLink? link;

  UserNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? date,
    NotificationType? type,
    bool? read,
    NotificationLink? link,
  }) {
    return UserNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      type: type ?? this.type,
      read: read ?? this.read,
      link: link ?? this.link,
    );
  }

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      date: json['date'] as String,
      type: NotificationType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => NotificationType.information,
      ),
      read: json['read'] as bool,
      link: json['link'] == null
          ? null
          : NotificationLink.fromJson(json['link'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'date': date,
        'type': type.name,
        'read': read,
        'link': link?.toJson(),
      };
}

enum AlertFrequency {
  daily('Quotidienne'),
  weekly('Hebdomadaire');

  const AlertFrequency(this.label);
  final String label;

  static AlertFrequency fromLabel(String label) {
    return AlertFrequency.values.firstWhere(
      (value) => value.label == label,
      orElse: () => AlertFrequency.daily,
    );
  }
}

class UserAlert {
  const UserAlert({
    required this.id,
    required this.title,
    required this.keywords,
    required this.location,
    required this.frequency,
    required this.lastRun,
    required this.active,
  });

  final String id;
  final String title;
  final List<String> keywords;
  final String location;
  final AlertFrequency frequency;
  final String lastRun;
  final bool active;

  UserAlert copyWith({
    String? id,
    String? title,
    List<String>? keywords,
    String? location,
    AlertFrequency? frequency,
    String? lastRun,
    bool? active,
  }) {
    return UserAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      keywords: keywords ?? this.keywords,
      location: location ?? this.location,
      frequency: frequency ?? this.frequency,
      lastRun: lastRun ?? this.lastRun,
      active: active ?? this.active,
    );
  }

  factory UserAlert.fromJson(Map<String, dynamic> json) {
    return UserAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      keywords: (json['keywords'] as List<dynamic>).cast<String>(),
      location: json['location'] as String,
      frequency: AlertFrequency.values.firstWhere(
        (value) => value.name == json['frequency'],
        orElse: () => AlertFrequency.daily,
      ),
      lastRun: json['lastRun'] as String,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'keywords': keywords,
        'location': location,
        'frequency': frequency.name,
        'lastRun': lastRun,
        'active': active,
      };
}

class UserCv {
  const UserCv({
    required this.id,
    required this.name,
    required this.updatedAt,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String updatedAt;
  final bool isPrimary;

  UserCv copyWith({
    String? id,
    String? name,
    String? updatedAt,
    bool? isPrimary,
  }) {
    return UserCv(
      id: id ?? this.id,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  factory UserCv.fromJson(Map<String, dynamic> json) {
    return UserCv(
      id: json['id'] as String,
      name: json['name'] as String,
      updatedAt: json['updatedAt'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'updatedAt': updatedAt,
        'isPrimary': isPrimary,
      };
}

enum ApplicationStatus {
  sent('Candidature envoyée'),
  inReview("En cours d'étude"),
  interview('Entretien planifié'),
  offer('Proposition reçue');

  const ApplicationStatus(this.label);
  final String label;

  static ApplicationStatus fromLabel(String label) {
    return ApplicationStatus.values.firstWhere(
      (value) => value.label == label,
      orElse: () => ApplicationStatus.sent,
    );
  }
}

class UserApplication {
  const UserApplication({
    required this.id,
    required this.jobId,
    required this.company,
    required this.title,
    required this.status,
    required this.lastUpdate,
    this.nextStep,
    required this.appliedOn,
    required this.notes,
  });

  final String id;
  final String jobId;
  final String company;
  final String title;
  final ApplicationStatus status;
  final String lastUpdate;
  final String? nextStep;
  final String appliedOn;
  final List<String> notes;

  UserApplication copyWith({
    String? id,
    String? jobId,
    String? company,
    String? title,
    ApplicationStatus? status,
    String? lastUpdate,
    String? nextStep,
    String? appliedOn,
    List<String>? notes,
  }) {
    return UserApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      company: company ?? this.company,
      title: title ?? this.title,
      status: status ?? this.status,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      nextStep: nextStep ?? this.nextStep,
      appliedOn: appliedOn ?? this.appliedOn,
      notes: notes ?? this.notes,
    );
  }

  factory UserApplication.fromJson(Map<String, dynamic> json) {
    return UserApplication(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      company: json['company'] as String,
      title: json['title'] as String,
      status: ApplicationStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => ApplicationStatus.sent,
      ),
      lastUpdate: json['lastUpdate'] as String,
      nextStep: json['nextStep'] as String?,
      appliedOn: json['appliedOn'] as String,
      notes: (json['notes'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobId': jobId,
        'company': company,
        'title': title,
        'status': status.name,
        'lastUpdate': lastUpdate,
        'nextStep': nextStep,
        'appliedOn': appliedOn,
        'notes': notes,
      };
}

class UserStats {
  const UserStats({
    required this.profileViews,
    required this.recruiterMessages,
    required this.applicationsInProgress,
  });

  final int profileViews;
  final int recruiterMessages;
  final int applicationsInProgress;

  UserStats copyWith({
    int? profileViews,
    int? recruiterMessages,
    int? applicationsInProgress,
  }) {
    return UserStats(
      profileViews: profileViews ?? this.profileViews,
      recruiterMessages: recruiterMessages ?? this.recruiterMessages,
      applicationsInProgress: applicationsInProgress ?? this.applicationsInProgress,
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      profileViews: json['profileViews'] as int,
      recruiterMessages: json['recruiterMessages'] as int,
      applicationsInProgress: json['applicationsInProgress'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'profileViews': profileViews,
        'recruiterMessages': recruiterMessages,
        'applicationsInProgress': applicationsInProgress,
      };
}

enum CookieConsent {
  essential('Essentiel'),
  complete('Complet');

  const CookieConsent(this.label);
  final String label;

  static CookieConsent fromLabel(String label) {
    return CookieConsent.values.firstWhere(
      (value) => value.label == label,
      orElse: () => CookieConsent.complete,
    );
  }
}

class UserSettings {
  const UserSettings({
    required this.pushNotifications,
    required this.emailSubscriptions,
    required this.cookieConsent,
    required this.accessibilityMode,
  });

  final bool pushNotifications;
  final bool emailSubscriptions;
  final CookieConsent cookieConsent;
  final bool accessibilityMode;

  UserSettings copyWith({
    bool? pushNotifications,
    bool? emailSubscriptions,
    CookieConsent? cookieConsent,
    bool? accessibilityMode,
  }) {
    return UserSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailSubscriptions: emailSubscriptions ?? this.emailSubscriptions,
      cookieConsent: cookieConsent ?? this.cookieConsent,
      accessibilityMode: accessibilityMode ?? this.accessibilityMode,
    );
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      pushNotifications: json['pushNotifications'] as bool,
      emailSubscriptions: json['emailSubscriptions'] as bool,
      cookieConsent: CookieConsent.values.firstWhere(
        (value) => value.name == json['cookieConsent'],
        orElse: () => CookieConsent.complete,
      ),
      accessibilityMode: json['accessibilityMode'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'pushNotifications': pushNotifications,
        'emailSubscriptions': emailSubscriptions,
        'cookieConsent': cookieConsent.name,
        'accessibilityMode': accessibilityMode,
      };
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarInitials,
    required this.title,
    required this.location,
    this.phone,
    this.bio,
    required this.hasPassword,
    required this.favorites,
    required this.alerts,
    required this.cvs,
    required this.applications,
    required this.notifications,
    required this.followedCompanies,
    required this.stats,
    required this.settings,
  });

  final String id;
  final String name;
  final String email;
  final String avatarInitials;
  final String title;
  final String location;
  final String? phone;
  final String? bio;
  final bool hasPassword;
  final List<String> favorites;
  final List<UserAlert> alerts;
  final List<UserCv> cvs;
  final List<UserApplication> applications;
  final List<UserNotification> notifications;
  final List<String> followedCompanies;
  final UserStats stats;
  final UserSettings settings;

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarInitials,
    String? title,
    String? location,
    String? phone,
    String? bio,
    bool? hasPassword,
    List<String>? favorites,
    List<UserAlert>? alerts,
    List<UserCv>? cvs,
    List<UserApplication>? applications,
    List<UserNotification>? notifications,
    List<String>? followedCompanies,
    UserStats? stats,
    UserSettings? settings,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      title: title ?? this.title,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      hasPassword: hasPassword ?? this.hasPassword,
      favorites: favorites ?? this.favorites,
      alerts: alerts ?? this.alerts,
      cvs: cvs ?? this.cvs,
      applications: applications ?? this.applications,
      notifications: notifications ?? this.notifications,
      followedCompanies: followedCompanies ?? this.followedCompanies,
      stats: stats ?? this.stats,
      settings: settings ?? this.settings,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarInitials: json['avatarInitials'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      hasPassword: json['hasPassword'] as bool,
      favorites: (json['favorites'] as List<dynamic>).cast<String>(),
      alerts: (json['alerts'] as List<dynamic>)
          .map((item) => UserAlert.fromJson(item as Map<String, dynamic>))
          .toList(),
      cvs: (json['cvs'] as List<dynamic>)
          .map((item) => UserCv.fromJson(item as Map<String, dynamic>))
          .toList(),
      applications: (json['applications'] as List<dynamic>)
          .map((item) => UserApplication.fromJson(item as Map<String, dynamic>))
          .toList(),
      notifications: (json['notifications'] as List<dynamic>)
          .map((item) => UserNotification.fromJson(item as Map<String, dynamic>))
          .toList(),
      followedCompanies:
          (json['followedCompanies'] as List<dynamic>).cast<String>(),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      settings:
          UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarInitials': avatarInitials,
        'title': title,
        'location': location,
        'phone': phone,
        'bio': bio,
        'hasPassword': hasPassword,
        'favorites': favorites,
        'alerts': alerts.map((alert) => alert.toJson()).toList(),
        'cvs': cvs.map((cv) => cv.toJson()).toList(),
        'applications':
            applications.map((application) => application.toJson()).toList(),
        'notifications':
            notifications.map((notification) => notification.toJson()).toList(),
        'followedCompanies': followedCompanies,
        'stats': stats.toJson(),
        'settings': settings.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());
}

AppUser cloneUser(AppUser user) {
  return AppUser.fromJson(jsonDecode(user.toJsonString()) as Map<String, dynamic>);
}

String extractInitials(String value) {
  final segments = value.trim().split(RegExp(r'\s+')).where((segment) => segment.isNotEmpty).toList();
  if (segments.isEmpty) {
    return 'US';
  }
  if (segments.length == 1) {
    return segments.first.substring(0, segments.first.length > 1 ? 2 : 1).toUpperCase();
  }
  return (segments.first[0] + segments.last[0]).toUpperCase();
}
