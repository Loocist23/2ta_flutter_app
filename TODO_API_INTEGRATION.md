# TODO : Améliorations de l'intégration API pour réduire les mocks

Ce document liste les améliorations potentielles pour mieux utiliser l'API réelle et réduire les données mockées dans l'application.

---

## 1. Remplacement des données mockées par des appels API réels

### Problème actuel
L'application utilise des données statiques dans :
- `lib/src/data/job_offers.dart` - Liste mockée des offres
- `lib/src/data/companies.dart` - Liste mockée des entreprises

### Solution proposée
Utiliser les endpoints API réels :
- **`GET /offers`** - Récupérer la liste des offres d'alternance
- **`GET /companies`** - Récupérer la liste des entreprises
- **`GET /offers/{id}`** - Récupérer les détails d'une offre spécifique

### Fichiers à modifier
- `lib/src/data/job_offers.dart` → Remplacer par un service API
- `lib/src/data/companies.dart` → Remplacer par un service API
- `lib/src/features/job_details/job_details_screen.dart` → Utiliser l'API pour les détails
- `lib/src/features/companies/company_screen.dart` → Utiliser l'API pour les infos entreprises

### Format des données API
L'API retourne les données au format Hydra/JSON-LD :
```json
{
  "hydra:member": [
    {
      "@id": "/api/offers/1",
      "id": 1,
      "title": "Développeur Web",
      "description": "Poste de développeur...",
      "company": "/api/companies/1",
      "rome": "/api/romes/1"
    }
  ],
  "hydra:totalItems": 1
}
```

---

## 2. Implémentation de l'OAuth réel

### Problème actuel
L'authentification OAuth utilise des simulations :
- `_simulateGoogleSignIn()` dans `auth_controller.dart`
- `_simulateAppleSignIn()` dans `auth_controller.dart`

### Solution proposée
Utiliser les endpoints OAuth réels de l'API :
- **`GET /connect/google`** - Redirection vers Google OAuth
- **`GET /connect/linkedin`** - Redirection vers LinkedIn OAuth

### Fichiers à modifier
- `lib/src/state/auth_controller.dart` → Remplacer les simulations par de vrais flows OAuth
- `lib/src/services/auth_api_service.dart` → Ajouter la gestion des redirections OAuth
- Ajouter des packages : `google_sign_in`, `sign_in_with_apple`

### Étapes d'implémentation
1. Configurer les clés API Google et Apple dans le projet
2. Implémenter les flows de redirection OAuth
3. Gérer les callbacks après authentification
4. Récupérer le token JWT via `/connect/register-oauth`

---

## 3. Utilisation des codes ROME de l'API

### Problème actuel
Les codes métiers (ROME) sont probablement mockés ou en dur dans le code.

### Solution proposée
Utiliser l'endpoint API dédié :
- **`GET /romes`** - Récupérer la liste des codes ROME

### Fichiers à modifier
- Créer un nouveau service `RomeApiService`
- Modifier les écrans de création/modification d'offres pour utiliser les vrais codes ROME
- Remplacer les listes statiques par des appels API

### Exemple de réponse API
```json
{
  "hydra:member": [
    {
      "@id": "/api/romes/M1805",
      "id": "M1805",
      "label": "Études et développement informatique",
      "description": "Conçoit, développe et maintient des applications..."
    }
  ]
}
```

---

## 4. Ajout de la gestion complète des entreprises

### Problème actuel
L'application semble principalement orientée étudiants. Les fonctionnalités entreprises sont absentes ou mockées.

### Solution proposée
Implémenter les endpoints entreprises :
- **`POST /companies`** - Création d'entreprise
- **`PATCH /companies/{id}`** - Mise à jour d'entreprise  
- **`DELETE /companies/{id}`** - Suppression d'entreprise

### Fichiers à ajouter/modifier
- Créer `lib/src/features/company_management/` avec les écrans CRUD
- Ajouter `CompanyApiService` pour gérer les appels API entreprises
- Modifier `auth_controller.dart` pour gérer les comptes entreprises
- Ajouter un flow d'inscription spécifique aux entreprises

### Cas d'usage
- Permettre aux entreprises de créer/modifier leurs profils
- Gérer la publication d'offres d'alternance
- Tableau de bord entreprise avec statistiques

---

## 5. Amélioration de la gestion des erreurs API

### Problème actuel
La gestion des erreurs est basique et pourrait être améliorée pour une meilleure UX.

### Solution proposée
- **Standardiser** la gestion des erreurs selon les codes API
- **Afficher des messages** plus clairs à l'utilisateur
- **Gérer les erreurs 401** avec reconnexion automatique
- **Journaliser les erreurs** pour le débogage

### Codes d'erreur à gérer
- **401 Unauthorized** : Token expiré → Déconnexion + redirection login
- **403 Forbidden** : Accès refusé → Message clair
- **404 Not Found** : Ressource introuvable → Message personnalisé
- **409 Conflict** : Email déjà utilisé → Suggestion de connexion
- **500 Server Error** : Erreur serveur → Message + bouton réessayer

### Fichiers à modifier
- `lib/src/services/api_service.dart` → Améliorer `_handleDioError()`
- `lib/src/utils/app_snackbar.dart` → Ajouter des messages standardisés
- Créer un système de logging des erreurs

---

## 6. Optimisation des performances API

### Problème actuel
Les appels API pourraient être optimisés pour une meilleure réactivité.

### Solutions proposées
- **Cache des données** : Stocker temporairement les listes (offres, entreprises)
- **Pagination** : Utiliser la pagination Hydra pour les longues listes
- **Loading states** : Améliorer les indicateurs de chargement
- **Refresh token** : Implémenter si l'API le supporte

### Exemple de pagination Hydra
```json
{
  "hydra:member": [],
  "hydra:totalItems": 100,
  "hydra:view": {
    "@id": "/api/offers?page=1",
    "@type": "PartialCollectionView",
    "hydra:first": "/api/offers?page=1",
    "hydra:last": "/api/offers?page=5",
    "hydra:next": "/api/offers?page=2"
  }
}
```

---

## Priorisation recommandée

1. **Critique** (à faire en priorité)
   - Remplacer les offres mockées par l'API réelle
   - Remplacer les entreprises mockées par l'API réelle

2. **Important** (améliore significativement l'expérience)
   - Implémenter l'OAuth réel (Google/Apple)
   - Améliorer la gestion des erreurs

3. **Optionnel** (fonctionnalités supplémentaires)
   - Ajouter la gestion complète des entreprises
   - Utiliser les codes ROME de l'API
   - Optimisations de performance

---

## Estimation de complexité

| Tâche | Complexité | Temps estimé |
|-------|------------|--------------|
| Remplacer offres mockées | Moyenne | 4-8h |
| Remplacer entreprises mockées | Moyenne | 3-6h |
| Implémenter OAuth réel | Élevée | 8-16h |
| Gestion entreprises complète | Très élevée | 16-32h |
| Codes ROME API | Faible | 2-4h |
| Amélioration erreurs | Moyenne | 4-8h |

---

## Dépendances à ajouter

```yaml
dependencies:
  google_sign_in: ^6.1.0
  sign_in_with_apple: ^4.3.0
  dio_cache_interceptor: ^3.4.2
  flutter_secure_storage: ^8.0.0
```

---

## Notes techniques

1. **Format des données** : L'API utilise JSON-LD/Hydra. Prévoir des adaptateurs pour convertir vers les modèles Dart.

2. **Authentication** : Tous les endpoints (sauf login) nécessitent le header `Authorization: Bearer <token>`.

3. **Content-Type** : Utiliser `application/ld+json` pour la plupart des endpoints, sauf PATCH qui utilise `application/merge-patch+json`.

4. **URL de base** : `https://api.trouvetonalternance.eu` (déjà configuré dans `ApiService`).

5. **Tests** : Prévoir des tests d'intégration pour valider les nouveaux appels API.

---

## Prochaines étapes suggérées

1. Commencer par remplacer les données mockées (offres et entreprises)
2. Tester chaque changement individuellement
3. Documenter les nouveaux services API créés
4. Mettre à jour les tests existants
5. Déployer les changements progressivement

Ce document peut servir de base pour créer des issues GitHub ou un plan de développement détaillé.