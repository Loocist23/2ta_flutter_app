import '../models/user.dart';

final AppUser mockUser = AppUser(
  id: 'user-1',
  name: 'Camille Martin',
  email: 'camille.martin@example.com',
  avatarInitials: 'CM',
  title: 'Étudiante en alternance — Développement Full-Stack',
  location: 'Paris (75)',
  phone: '+33 6 12 34 56 78',
  bio:
  "Étudiante en informatique, je recherche une alternance en développement (backend, frontend ou full-stack). À l’aise avec les API, les bases de données et le travail en équipe Agile.",
  hasPassword: false,
  favorites: const ['job-1', 'job-3'],
  alerts: const [
    UserAlert(
      id: 'alert-1',
      title: 'Alternance Développeur Full-Stack — Télétravail/Hybride',
      keywords: ['Alternance', 'React', 'Node', 'API', 'SQL'],
      location: 'Télétravail',
      frequency: AlertFrequency.daily,
      lastRun: 'Il y a 2 heures',
      active: true,
    ),
    UserAlert(
      id: 'alert-2',
      title: 'Alternance Développeur Flutter — Paris',
      keywords: ['Alternance', 'Flutter', 'Dart', 'Mobile'],
      location: 'Paris (75)',
      frequency: AlertFrequency.daily,
      lastRun: 'Hier',
      active: true,
    ),
    UserAlert(
      id: 'alert-3',
      title: 'Alternance Développeur .NET — Lyon',
      keywords: ['Alternance', 'C#', '.NET', 'SQL'],
      location: 'Lyon (69)',
      frequency: AlertFrequency.weekly,
      lastRun: 'Il y a 3 jours',
      active: false,
    ),
  ],
  cvs: const [
    UserCv(
      id: 'cv-1',
      name: 'CV_Alternance_Developpeur.pdf',
      updatedAt: 'Mis à jour il y a 5 jours',
      isPrimary: true,
    ),
    UserCv(
      id: 'cv-2',
      name: 'Portfolio_Projets.pdf',
      updatedAt: 'Mis à jour il y a 12 jours',
    ),
  ],
  applications: const [
    UserApplication(
      id: 'application-1',
      jobId: 'job-1',
      company: 'HelloWork',
      title: 'Développeur Full-Stack (Alternance)',
      status: ApplicationStatus.interview,
      lastUpdate: 'Entretien technique prévu demain',
      nextStep: 'Réviser API + SQL, préparer 2 projets à présenter',
      appliedOn: 'Candidature envoyée il y a 6 jours',
      notes: ['Bonne accroche sur les projets perso', 'Penser à demander le rythme (1/3, 2/3, etc.)'],
    ),
    UserApplication(
      id: 'application-2',
      jobId: 'job-4',
      company: 'SaaSly',
      title: 'Data Analyst (Alternance)',
      status: ApplicationStatus.sent,
      lastUpdate: 'Envoyée il y a 3 jours',
      appliedOn: 'Envoyée il y a 3 jours',
      notes: ['Adapter le CV pour mettre SQL en avant'],
    ),
    UserApplication(
      id: 'application-3',
      jobId: 'job-3',
      company: 'RetailX',
      title: 'Développeur .NET / C# (Alternance)',
      status: ApplicationStatus.inReview,
      lastUpdate: 'Candidature en cours de lecture',
      appliedOn: 'Envoyée il y a 1 semaine',
      notes: ['Relancer si pas de réponse sous 7-10 jours'],
    ),
  ],
  notifications: const [
    UserNotification(
      id: 'notification-1',
      title: 'Entretien confirmé',
      message: "HelloWork a confirmé un entretien pour votre candidature en alternance.",
      date: 'Il y a 2 heures',
      type: NotificationType.application,
      read: false,
      link: NotificationLink(
        type: NotificationLinkType.application,
        targetId: 'application-1',
      ),
    ),
    UserNotification(
      id: 'notification-2',
      title: 'Nouvelles offres',
      message: '4 nouvelles offres correspondent à votre alerte "Full-Stack — Télétravail/Hybride".',
      date: 'Il y a 5 heures',
      type: NotificationType.alert,
      read: false,
      link: NotificationLink(
        type: NotificationLinkType.alert,
        targetId: 'alert-1',
      ),
    ),
    UserNotification(
      id: 'notification-3',
      title: 'Conseil candidature',
      message: "Pensez à préciser votre rythme d’alternance et votre date de démarrage dans vos candidatures.",
      date: 'Hier',
      type: NotificationType.information,
      read: true,
    ),
  ],
  followedCompanies: const ['company-hellowork'],
  stats: const UserStats(
    profileViews: 84,
    recruiterMessages: 2,
    applicationsInProgress: 3,
  ),
  settings: const UserSettings(
    pushNotifications: true,
    emailSubscriptions: true,
    cookieConsent: CookieConsent.complete,
    accessibilityMode: false,
  ),
);

AppUser createDefaultUser({
  String? id,
  String? email,
  String? name,
  String? avatarInitials,
  bool? hasPassword,
}) {
  final cloned = cloneUser(mockUser);
  return cloned.copyWith(
    id: id ?? cloned.id,
    email: email ?? cloned.email,
    name: name ?? cloned.name,
    avatarInitials: avatarInitials ?? cloned.avatarInitials,
    hasPassword: hasPassword ?? cloned.hasPassword,
  );
}
