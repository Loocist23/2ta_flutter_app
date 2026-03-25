# Configuration de l'icône et de la police Montserrat

Ce document explique les changements apportés pour configurer l'icône de l'application et la police Montserrat.

## Changements effectués

### 1. Fichiers de configuration créés

#### `flutter_launcher_icons.yaml`
Configuration pour générer les icônes de l'application sur toutes les plateformes à partir de `assets/images/app_icon.png`.

#### `flutter_native_splash.yaml`
Configuration pour générer un écran de splash avec l'icône de l'application.

### 2. Modifications dans `pubspec.yaml`

- **Ajout des dépendances** :
  ```yaml
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.3.1
  ```

- **Configuration des assets** :
  ```yaml
  assets:
    - assets/images/app_icon.png
  ```

- **Configuration de la police Montserrat** :
  ```yaml
  fonts:
    - family: Montserrat
      fonts:
        - asset: assets/fonts/Montserrat-Regular.ttf
        - asset: assets/fonts/Montserrat-Medium.ttf
          weight: 500
        - asset: assets/fonts/Montserrat-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Montserrat-Bold.ttf
          weight: 700
  ```

### 3. Modifications dans `app_theme.dart`

- Ajout de `fontFamily: 'Montserrat'` au thème global
- Application de la police Montserrat à tous les éléments du thème :
  - `appBarTheme`
  - `textTheme` (tous les styles de texte)
  - `inputDecorationTheme`
  - `chipTheme`
  - `buttonTheme`
  - `elevatedButtonTheme`
  - `outlinedButtonTheme`
  - `textButtonTheme`

## Étapes pour finaliser la configuration

### 1. Ajouter l'icône de l'application
Placer votre fichier `app_icon.png` dans `assets/images/app_icon.png`.

### 2. Ajouter les fichiers de police Montserrat
Télécharger les fichiers TTF de Montserrat et les placer dans `assets/fonts/` :
- Montserrat-Regular.ttf
- Montserrat-Medium.ttf
- Montserrat-SemiBold.ttf
- Montserrat-Bold.ttf

### 3. Générer les icônes et le splash screen
Exécuter les commandes suivantes :

```bash
# Générer les icônes de l'application
flutter pub run flutter_launcher_icons:main

# Générer le splash screen
flutter pub run flutter_native_splash:create
```

### 4. Mettre à jour les dépendances
```bash
flutter pub get
```

## Personnalisation supplémentaire

### Couleurs du splash screen
Modifier dans `flutter_native_splash.yaml` :
- `color` : Couleur de fond pour le mode clair
- `color_dark` : Couleur de fond pour le mode sombre

### Taille de l'icône
Modifier dans `flutter_launcher_icons.yaml` selon vos besoins.

## Notes importantes

1. **Format de l'icône** : L'icône doit être carrée et de préférence en PNG avec transparence.

2. **Taille recommandée** : 1024x1024 pixels pour une meilleure qualité sur toutes les plateformes.

3. **Police Montserrat** : Assurez-vous d'avoir les droits d'utilisation de cette police pour votre application.

4. **Test** : Après génération, tester sur différentes plateformes pour vérifier l'affichage.

## Fichiers créés/modifiés

- ✅ `flutter_launcher_icons.yaml` (nouveau)
- ✅ `flutter_native_splash.yaml` (nouveau)
- ✅ `pubspec.yaml` (modifié)
- ✅ `lib/src/theme/app_theme.dart` (modifié)
- ❌ `assets/images/app_icon.png` (à ajouter)
- ❌ `assets/fonts/Montserrat-*.ttf` (à ajouter)

## Commandes utiles

```bash
# Pour regénérer les icônes après modification
flutter pub run flutter_launcher_icons:main

# Pour regénérer le splash screen
flutter pub run flutter_native_splash:create

# Pour nettoyer et regénérer
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons:main
flutter pub run flutter_native_splash:create
```