import '../models/highlighted_topic.dart';
import '../models/job_offer.dart';

const jobOffers = <JobOffer>[
  JobOffer(
    id: 'job-1',
    title: 'Développeur Full-Stack (Alternance)',
    company: 'HelloWork',
    companyId: 'company-hellowork',
    location: 'Paris (75)',
    contract: "Contrat d'apprentissage",
    salary: '900 - 1 300 € / mois',
    postedAt: 'Publié il y a 2 heures',
    remoteType: 'Hybride',
    tags: ['React', 'Node.js', 'PostgreSQL'],
    description:
    "Intégrez une équipe produit et participez au développement d'une plateforme web à fort trafic (features, tests, CI/CD).",
  ),
  JobOffer(
    id: 'job-2',
    title: 'Développeur Flutter (Alternance)',
    company: 'ScaleUp Labs',
    companyId: 'company-scaleup',
    location: 'Lille (59)',
    contract: "Contrat d'apprentissage",
    salary: '850 - 1 250 € / mois',
    postedAt: 'Publié hier',
    remoteType: 'Télétravail',
    tags: ['Flutter', 'Dart', 'REST API'],
    description:
    "Développez des fonctionnalités mobiles, améliorez les performances et travaillez en lien direct avec le backend et le design.",
  ),
  JobOffer(
    id: 'job-3',
    title: 'Développeur .NET / C# (Alternance)',
    company: 'RetailX',
    companyId: 'company-retailx',
    location: 'Lyon (69)',
    contract: 'Contrat de professionnalisation',
    salary: '1 000 - 1 400 € / mois',
    postedAt: 'Publié il y a 3 jours',
    remoteType: 'Hybride',
    tags: ['C#', '.NET', 'SQL'],
    description:
    "Participez au développement d'APIs et services internes (auth, données, intégrations) avec une approche qualité et monitoring.",
  ),
  JobOffer(
    id: 'job-4',
    title: 'Data Analyst (Alternance)',
    company: 'SaaSly',
    companyId: 'company-saasly',
    location: 'Télétravail',
    contract: "Contrat d'apprentissage",
    salary: '800 - 1 200 € / mois',
    postedAt: 'Publié il y a 4 jours',
    remoteType: 'Télétravail',
    tags: ['SQL', 'Python', 'Power BI'],
    description:
    "Aidez à structurer les dashboards et l'analyse produit : extraction SQL, scripts Python, indicateurs et automatisation des reportings.",
  ),
  JobOffer(
    id: 'job-5',
    title: 'Développeur Backend Node.js (Alternance)',
    company: 'GreenTech',
    companyId: 'company-greentech',
    location: 'Bordeaux (33)',
    contract: "Contrat d'apprentissage",
    salary: '900 - 1 300 € / mois',
    postedAt: 'Publié il y a 5 jours',
    remoteType: 'Hybride',
    tags: ['Node.js', 'Express', 'Docker'],
    description:
    "Développez des endpoints API, améliorez la sécurité (auth/roles), et participez au déploiement via Docker et pipelines CI.",
  ),
  JobOffer(
    id: 'job-6',
    title: 'Développeur Frontend React (Alternance)',
    company: 'Nova Studio',
    companyId: 'company-nova',
    location: 'Rennes (35)',
    contract: 'Contrat de professionnalisation',
    salary: '750 - 1 150 € / mois',
    postedAt: 'Publié cette semaine',
    remoteType: 'Présentiel',
    tags: ['React', 'TypeScript', 'Tailwind'],
    description:
    "Contribuez à l'interface d'un produit web : composants, intégration UI, accessibilité, et collaboration avec le design.",
  ),
];

const highlightedTopics = [
  HighlightedTopic(
    id: 'topic-1',
    title: 'Trouver mon alternance 2026',
    description:
    'Métiers qui recrutent, rythme école/entreprise, et secteurs les plus actifs en France.',
  ),
  HighlightedTopic(
    id: 'topic-2',
    title: 'Optimiser mon CV (Alternance)',
    description:
    "Projets à mettre en avant, mots-clés ATS, et exemples de CV qui passent en présélection.",
  ),
  HighlightedTopic(
    id: 'topic-3',
    title: 'Réussir mes entretiens',
    description:
    'Questions fréquentes, tests techniques, et comment parler de vos projets et de votre motivation.',
  ),
];
