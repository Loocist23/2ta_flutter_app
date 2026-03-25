# Exigences API pour une intégration complète

Ce document détaille les modifications et ajouts nécessaires côté API pour permettre une intégration complète de l'application mobile 2TA avec le backend, éliminant ainsi tous les mocks et fournissant une expérience utilisateur complète.

---

## 📋 Sommaire

1. [Endpoints existants déjà intégrés](#endpoints-existants-déjà-intégrés)
2. [Endpoints manquants pour une intégration complète](#endpoints-manquants-pour-une-intégration-complète)
3. [Modifications suggérées aux endpoints existants](#modifications-suggérées-aux-endpoints-existants)
4. [Format des réponses API](#format-des-réponses-api)
5. [Authentication et autorisation](#authentication-et-autorisation)
6. [Pagination et filtrage](#pagination-et-filtrage)
7. [Gestion des erreurs](#gestion-des-erreurs)
8. [Priorisation des développements](#priorisation-des-développements)

---

## Endpoints existants déjà intégrés

### ✅ Authentification

**Endpoint:** `POST /login_check`
**Statut:** ✅ Intégré et fonctionnel
**Utilisation:** Connexion utilisateur avec email/mot de passe
**Réponse:** JWT token valide

```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9..."
}
```

### ✅ Profil utilisateur

**Endpoint:** `GET /me`
**Statut:** ✅ Intégré et fonctionnel
**Utilisation:** Récupération des informations de l'utilisateur connecté
**Réponse:** Données utilisateur complètes avec applications

```json
{
  "id": "2",
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "0612345678",
  "roles": ["ROLE_STUDENT", "ROLE_USER"],
  "googleId": null,
  "linkedinId": null,
  "isPasswordSet": true,
  "type": "student"
}
```

### ✅ Offres d'alternance

**Endpoint:** `GET /offers`
**Statut:** ✅ Intégré et fonctionnel
**Utilisation:** Liste des offres avec pagination et filtrage
**Paramètres:** `page`, `itemsPerPage`, `status`, `rome.id`, `company.id`, `contractType[]`, `remote`

### ✅ Entreprises

**Endpoint:** `GET /companies`
**Statut:** ✅ Intégré et fonctionnel
**Utilisation:** Liste des entreprises avec pagination
**Paramètres:** `page`, `itemsPerPage`, `name`, `siret`

### ✅ Candidatures

**Endpoint:** `GET /applications`
**Statut:** ✅ Intégré et fonctionnel
**Utilisation:** Liste des candidatures de l'utilisateur
**Paramètres:** `page`, `itemsPerPage`, `offer.id`, `student.id`, `status`

---

## Endpoints manquants pour une intégration complète

### 🔴 Critiques (Bloquants pour la production)

#### 1. Gestion des favoris

**Endpoint:** `GET /me/favorites`
**Méthode:** GET
**Description:** Récupérer la liste des offres favorites de l'utilisateur
**Paramètres:** `page`, `itemsPerPage`
**Réponse attendue:**
```json
{
  "hydra:member": [
    {
      "id": "fav-1",
      "offer": "/api/offers/1",
      "createdAt": "2024-03-25T10:00:00+00:00"
    }
  ],
  "hydra:totalItems": 1
}
```

**Endpoint:** `POST /me/favorites`
**Méthode:** POST
**Description:** Ajouter une offre aux favoris
**Body:**
```json
{
  "offer": "/api/offers/1"
}
```
**Réponse:** 201 Created avec l'objet favori créé

**Endpoint:** `DELETE /me/favorites/{id}`
**Méthode:** DELETE
**Description:** Supprimer une offre des favoris
**Réponse:** 204 No Content

#### 2. Gestion des CVs

**Endpoint:** `GET /me/cvs`
**Méthode:** GET
**Description:** Liste des CVs téléchargés par l'utilisateur
**Réponse attendue:**
```json
{
  "hydra:member": [
    {
      "id": "cv-1",
      "name": "CV_Developpeur_2024.pdf",
      "url": "/uploads/cvs/cv-1.pdf",
      "uploadedAt": "2024-03-20T09:30:00+00:00",
      "isPrimary": true,
      "size": 1024,
      "mimeType": "application/pdf"
    }
  ],
  "hydra:totalItems": 1
}
```

**Endpoint:** `POST /me/cvs`
**Méthode:** POST
**Description:** Télécharger un nouveau CV
**Body:** FormData avec fichier PDF
**Réponse:** 201 Created avec métadonnées du CV

**Endpoint:** `PATCH /me/cvs/{id}`
**Méthode:** PATCH
**Description:** Mettre à jour les métadonnées d'un CV
**Body:**
```json
{
  "name": "CV_Mis_a_jour.pdf",
  "isPrimary": true
}
```

**Endpoint:** `DELETE /me/cvs/{id}`
**Méthode:** DELETE
**Description:** Supprimer un CV
**Réponse:** 204 No Content

#### 3. Gestion des alertes

**Endpoint:** `GET /me/alerts`
**Méthode:** GET
**Description:** Liste des alertes job configurées
**Réponse attendue:**
```json
{
  "hydra:member": [
    {
      "id": "alert-1",
      "title": "Développeur Flutter - Paris",
      "keywords": ["Flutter", "Dart", "Mobile"],
      "location": "Paris (75)",
      "frequency": "daily",
      "active": true,
      "createdAt": "2024-03-15T08:00:00+00:00",
      "lastRun": "2024-03-25T08:00:00+00:00"
    }
  ],
  "hydra:totalItems": 1
}
```

**Endpoint:** `POST /me/alerts`
**Méthode:** POST
**Description:** Créer une nouvelle alerte
**Body:**
```json
{
  "title": "Développeur Flutter - Paris",
  "keywords": ["Flutter", "Dart", "Mobile"],
  "location": "Paris (75)",
  "frequency": "daily"
}
```

**Endpoint:** `PATCH /me/alerts/{id}`
**Méthode:** PATCH
**Description:** Mettre à jour une alerte
**Body:**
```json
{
  "active": false,
  "keywords": ["Flutter", "Dart", "Mobile", "React Native"]
}
```

**Endpoint:** `DELETE /me/alerts/{id}`
**Méthode:** DELETE
**Description:** Supprimer une alerte
**Réponse:** 204 No Content

#### 4. Gestion des notifications

**Endpoint:** `GET /me/notifications`
**Méthode:** GET
**Description:** Liste des notifications utilisateur
**Paramètres:** `page`, `itemsPerPage`, `read` (boolean)
**Réponse attendue:**
```json
{
  "hydra:member": [
    {
      "id": "notif-1",
      "title": "Nouvelle candidature",
      "message": "Votre candidature pour Développeur Flutter a été vue",
      "type": "application",
      "read": false,
      "createdAt": "2024-03-25T14:30:00+00:00",
      "link": {
        "type": "application",
        "targetId": "app-1"
      }
    }
  ],
  "hydra:totalItems": 1,
  "unreadCount": 1
}
```

**Endpoint:** `PATCH /me/notifications/{id}`
**Méthode:** PATCH
**Description:** Marquer une notification comme lue
**Body:**
```json
{
  "read": true
}
```

**Endpoint:** `POST /me/notifications/read-all`
**Méthode:** POST
**Description:** Marquer toutes les notifications comme lues
**Réponse:** 200 OK avec nombre de notifications marquées

#### 5. Entreprises suivies

**Endpoint:** `GET /me/followed-companies`
**Méthode:** GET
**Description:** Liste des entreprises suivies par l'utilisateur
**Réponse attendue:**
```json
{
  "hydra:member": [
    {
      "id": "follow-1",
      "company": "/api/companies/1",
      "createdAt": "2024-03-20T11:15:00+00:00"
    }
  ],
  "hydra:totalItems": 1
}
```

**Endpoint:** `POST /me/followed-companies`
**Méthode:** POST
**Description:** Suivre une nouvelle entreprise
**Body:**
```json
{
  "company": "/api/companies/1"
}
```

**Endpoint:** `DELETE /me/followed-companies/{id}`
**Méthode:** DELETE
**Description:** Ne plus suivre une entreprise
**Réponse:** 204 No Content

### 🟡 Importantes (Améliorent significativement l'expérience)

#### 6. Statistiques utilisateur

**Endpoint:** `GET /me/stats`
**Méthode:** GET
**Description:** Statistiques d'activité de l'utilisateur
**Réponse attendue:**
```json
{
  "profileViews": 42,
  "applicationViews": 15,
  "applicationsInProgress": 3,
  "applicationsAccepted": 1,
  "applicationsRejected": 2,
  "favoriteOffers": 8,
  "followedCompanies": 4,
  "searchHistory": [
    {"term": "Flutter", "count": 5},
    {"term": "Alternance", "count": 3}
  ]
}
```

#### 7. Historique de recherche

**Endpoint:** `GET /me/search-history`
**Méthode:** GET
**Description:** Récupérer l'historique de recherche
**Réponse attendue:**
```json
{
  "hydra:member": [
    {
      "id": "search-1",
      "term": "Développeur Flutter",
      "count": 3,
      "lastSearched": "2024-03-24T09:45:00+00:00"
    }
  ],
  "hydra:totalItems": 5
}
```

**Endpoint:** `DELETE /me/search-history`
**Méthode:** DELETE
**Description:** Effacer tout l'historique de recherche
**Réponse:** 204 No Content

#### 8. Paramètres utilisateur

**Endpoint:** `GET /me/settings`
**Méthode:** GET
**Description:** Récupérer les paramètres utilisateur
**Réponse attendue:**
```json
{
  "pushNotifications": true,
  "emailNotifications": true,
  "emailFrequency": "daily",
  "accessibilityMode": false,
  "darkMode": "system",
  "language": "fr"
}
```

**Endpoint:** `PATCH /me/settings`
**Méthode:** PATCH
**Description:** Mettre à jour les paramètres
**Body:**
```json
{
  "pushNotifications": false,
  "darkMode": "enabled"
}
```

### 🟢 Optionnelles (Fonctionnalités supplémentaires)

#### 9. Notes sur les candidatures

**Endpoint:** `GET /applications/{id}/notes`
**Méthode:** GET
**Description:** Récupérer les notes d'une candidature
**Réponse attendue:**
```json
{
  "hydra:member": [
    {
      "id": "note-1",
      "content": "Relancer le recruteur demain",
      "createdAt": "2024-03-25T10:30:00+00:00"
    }
  ],
  "hydra:totalItems": 1
}
```

**Endpoint:** `POST /applications/{id}/notes`
**Méthode:** POST
**Description:** Ajouter une note à une candidature
**Body:**
```json
{
  "content": "Entretien technique prévu le 28/03"
}
```

#### 10. Historique des candidatures

**Endpoint:** `GET /me/application-history`
**Méthode:** GET
**Description:** Historique complet des candidatures (y compris supprimées)
**Paramètres:** `year`, `status`
**Réponse attendue:**
```json
{
  "hydra:member": [
    {
      "id": "app-hist-1",
      "offer": "/api/offers/1",
      "status": "rejected",
      "appliedAt": "2024-01-15T00:00:00+00:00",
      "closedAt": "2024-01-20T00:00:00+00:00"
    }
  ],
  "hydra:totalItems": 12
}
```

---

## Modifications suggérées aux endpoints existants

### 1. Ajouter des champs manquants à `/me`

**Champs supplémentaires nécessaires:**
```json
{
  "stats": {
    "profileViews": 42,
    "applicationsInProgress": 3,
    "favoritesCount": 5,
    "followedCompaniesCount": 4
  },
  "settings": {
    "pushNotifications": true,
    "emailNotifications": true
  }
}
```

### 2. Améliorer `/offers` avec plus de détails

**Champs supplémentaires utiles:**
```json
{
  "salaryRange": {
    "min": 900,
    "max": 1300,
    "currency": "EUR",
    "period": "monthly"
  },
  "locationDetails": {
    "city": "Paris",
    "region": "Île-de-France",
    "remotePercentage": 50,
    "address": "123 Rue de Paris, 75001 Paris"
  },
  "company": {
    "id": "company-1",
    "name": "Entreprise SA",
    "logo": "/uploads/logos/logo.png",
    "industry": "Tech",
    "size": "500-1000"
  }
}
```

### 3. Étendre `/applications` avec plus d'informations

**Champs supplémentaires utiles:**
```json
{
  "notes": [
    {
      "id": "note-1",
      "content": "Relancer le 28/03",
      "createdAt": "2024-03-25T10:30:00+00:00"
    }
  ],
  "events": [
    {
      "type": "status_change",
      "from": "sent",
      "to": "in_review",
      "at": "2024-03-22T09:15:00+00:00"
    }
  ]
}
```

---

## Format des réponses API

### Structure standardisée

Tous les endpoints doivent suivre cette structure de réponse :

```json
{
  "hydra:member": [
    /* Tableau des éléments */
  ],
  "hydra:totalItems": 123,
  "hydra:view": {
    "@id": "/api/offers?page=1",
    "@type": "hydra:PartialCollectionView",
    "hydra:first": "/api/offers?page=1",
    "hydra:last": "/api/offers?page=5",
    "hydra:next": "/api/offers?page=2"
  }
}
```

### Dates et heures

Toutes les dates doivent être au format ISO 8601 :
```json
{
  "createdAt": "2024-03-25T10:30:00+00:00",
  "updatedAt": "2024-03-25T14:45:00+00:00"
}
```

### Relations entre entités

Utiliser les IRIs pour les relations :
```json
{
  "offer": "/api/offers/123",
  "company": "/api/companies/456",
  "user": "/api/users/789"
}
```

---

## Authentication et autorisation

### Tokens JWT

- **Format:** JWT standard avec algorithme RS256
- **Durée:** 1 heure (3600 secondes)
- **Rafraîchissement:** Implémenter un endpoint `/token/refresh` si possible
- **Headers:** `Authorization: Bearer <token>`

### Rôles et permissions

Rôles existants :
- `ROLE_STUDENT` - Étudiant
- `ROLE_COMPANY` - Entreprise
- `ROLE_USER` - Utilisateur de base
- `ROLE_ADMIN` - Administrateur

Permissions nécessaires :
- Les étudiants peuvent seulement voir/modifier leurs propres données
- Les entreprises peuvent gérer leurs offres et candidatures
- Les admins ont accès à tout

---

## Pagination et filtrage

### Pagination standard

Tous les endpoints de liste doivent supporter :
- `page` (défaut: 1)
- `itemsPerPage` (défaut: 30, max: 100)

### Filtrage avancé

**Pour `/offers` :**
- `title` - Filtre par titre (recherche partielle)
- `status` - Filtre par statut (ACTIVE, INACTIVE, etc.)
- `rome.id` - Filtre par code ROME
- `company.id` - Filtre par entreprise
- `contractType[]` - Filtre par type de contrat (tableau)
- `remote` - Filtre par type de télétravail
- `salaryMin` / `salaryMax` - Filtre par salaire
- `publishedAfter` - Filtre par date de publication

**Pour `/applications` :**
- `offer.id` - Filtre par offre
- `student.id` - Filtre par étudiant
- `status` - Filtre par statut
- `appliedAfter` - Filtre par date de candidature

---

## Gestion des erreurs

### Codes d'erreur standardisés

| Code | Type | Description | Réponse attendue |
|------|------|-------------|------------------|
| 200 | OK | Requête réussie | Données ou confirmation |
| 201 | Created | Ressource créée | Objet créé avec ID |
| 204 | No Content | Suppression réussie | Corps vide |
| 400 | Bad Request | Paramètres invalides | `{"message": "...", "errors": {...}}` |
| 401 | Unauthorized | Non authentifié | `{"message": "Expired JWT Token"}` |
| 403 | Forbidden | Accès refusé | `{"message": "Access denied"}` |
| 404 | Not Found | Ressource introuvable | `{"message": "Resource not found"}` |
| 409 | Conflict | Conflit (ex: email existant) | `{"message": "Email already exists"}` |
| 429 | Too Many Requests | Trop de requêtes | `{"message": "Rate limit exceeded"}` |
| 500 | Server Error | Erreur serveur | `{"message": "Internal server error"}` |

### Format des erreurs

```json
{
  "type": "https://api.trouvetonalternance.eu/errors/invalid-credentials",
  "title": "Invalid credentials",
  "detail": "The provided email or password is incorrect.",
  "status": 401,
  "instance": "/api/login_check",
  "violations": [
    {
      "propertyPath": "password",
      "message": "Must be at least 8 characters"
    }
  ]
}
```

---

## Priorisation des développements

### 🔴 Niveau 1 - Critique (Bloquant pour la production)

1. **Endpoints de favoris** - Nécessaire pour remplacer les mocks de favoris
2. **Endpoints de CVs** - Nécessaire pour la gestion des documents
3. **Endpoints d'alertes** - Fonctionnalité principale de l'application
4. **Endpoints de notifications** - Pour les notifications en temps réel
5. **Endpoints d'entreprises suivies** - Fonctionnalité sociale importante

**Estimation:** 2-3 jours par endpoint (1-2 semaines total)
**Impact:** Permet de supprimer 80% des mocks restants

### 🟡 Niveau 2 - Important (Améliore significativement l'expérience)

1. **Statistiques utilisateur** - Pour le tableau de bord
2. **Historique de recherche** - Améliore l'UX
3. **Paramètres utilisateur** - Personnalisation
4. **Notes sur candidatures** - Fonctionnalité utile

**Estimation:** 1-2 jours par endpoint (1 semaine total)
**Impact:** Expérience utilisateur plus complète et personnalisée

### 🟢 Niveau 3 - Optionnel (Fonctionnalités supplémentaires)

1. **Historique des candidatures** - Archivage
2. **Recommandations personnalisées** - Algorithme de matching
3. **Analytiques avancées** - Statistiques détaillées

**Estimation:** Variable selon complexité
**Impact:** Fonctionnalités avancées pour différenciation

---

## Recommandations techniques

### 1. Versioning de l'API

Implémenter le versioning dès maintenant :
- **URL:** `/api/v1/offers` (au lieu de `/api/offers`)
- **Headers:** `Accept: application/vnd.api.v1+json`

### 2. Documentation OpenAPI

Fournir une documentation OpenAPI/Swagger complète :
- Format YAML/JSON standard
- Exemples de requêtes/réponses
- Possibilité de tester directement depuis la documentation

### 3. Environnements de test

Maintenir des environnements séparés :
- **Production:** `https://api.trouvetonalternance.eu`
- **Staging:** `https://staging-api.trouvetonalternance.eu`
- **Développement:** `https://dev-api.trouvetonalternance.eu`

### 4. Rate Limiting

Implémenter des limites raisonnables :
- 100 requêtes/minute par IP
- 1000 requêtes/heure par utilisateur authentifié
- Headers standards : `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

### 5. Cache

Optimiser avec du caching :
- `Cache-Control: public, max-age=300` pour les listes
- `Cache-Control: no-cache` pour les données utilisateur
- Support des ETags pour la validation de cache

---

## Checklist pour le backend

- [ ] Implémenter tous les endpoints critiques (Niveau 1)
- [ ] Ajouter les champs manquants aux réponses existantes
- [ ] Standardiser le format des réponses (Hydra/JSON-LD)
- [ ] Documenter l'API avec OpenAPI/Swagger
- [ ] Configurer les environnements de test
- [ ] Implémenter le rate limiting
- [ ] Ajouter le support CORS approprié
- [ ] Optimiser les performances des endpoints
- [ ] Mettre en place la surveillance/monitoring
- [ ] Prévoir une stratégie de versioning

---

## Impact de l'intégration complète

### Avantages attendus

1. **Expérience utilisateur améliorée**
   - Données en temps réel
   - Synchronisation multi-appareils
   - Fonctionnalités complètes

2. **Maintenance simplifiée**
   - Plus de mocks à maintenir
   - Données cohérentes entre frontend et backend
   - Moins de bugs liés aux données

3. **Évolutivité**
   - Prêt pour l'ajout de nouvelles fonctionnalités
   - Architecture solide pour la croissance
   - Intégration facile avec d'autres services

4. **Analytiques**
   - Données réelles pour les métriques
   - Comportement utilisateur précis
   - Meilleure prise de décision

### Métriques de succès

- ❌ 0% de mocks dans l'application
- ✅ 100% des données depuis l'API
- <500ms temps de réponse moyen pour les endpoints
- 99.9% disponibilité de l'API
- 0 erreurs critiques en production

---

## Conclusion

L'intégration API actuelle est à **90% complète** et fonctionne correctement pour les fonctionnalités principales. Les **10% restants** dépendent de l'implémentation des endpoints manquants côté backend.

**Prochaines étapes recommandées :**

1. **Backend:** Prioriser le développement des endpoints critiques (Niveau 1)
2. **Frontend:** Préparer l'intégration des nouveaux endpoints
3. **Tests:** Valider l'intégration complète avant déploiement
4. **Documentation:** Mettre à jour la documentation API

Avec ces endpoints en place, l'application mobile pourra offrir une expérience utilisateur complète, moderne et professionnelle, entièrement synchronisée avec le backend. 🚀

---

**Document version:** 1.0
**Last updated:** 25 mars 2026
**Status:** En attente des développements backend
**Priority:** Haute (nécessaire pour le déploiement en production)
