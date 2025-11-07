# Application Immobilier - Flutter

Application mobile pour la recherche, consultation et publication d'annonces immobilières.

## 🚀 Installation

### Prérequis

- Flutter SDK (>= 3.0.0)
- Dart SDK
- Android Studio ou Xcode (pour iOS)
- Émulateur Android/iOS ou appareil physique

### Étapes d'installation

1. **Cloner le projet** (ou créer le dossier)
```bash
flutter create immobilier_app
cd immobilier_app
```

2. **Copier tous les fichiers fournis** dans la structure suivante :
```
lib/
  ├── main.dart
  ├── models/
  │   ├── user.dart
  │   ├── property.dart
  │   └── message.dart
  ├── providers/
  │   ├── auth_provider.dart
  │   ├── property_provider.dart
  │   └── message_provider.dart
  ├── screens/
  │   ├── auth/
  │   │   ├── login_screen.dart
  │   │   └── register_screen.dart
  │   ├── home/
  │   │   └── home_screen.dart
  │   ├── property/
  │   │   ├── property_detail_screen.dart
  │   │   └── add_property_screen.dart
  │   ├── search/
  │   │   └── search_screen.dart
  │   ├── favorites/
  │   │   └── favorites_screen.dart
  │   ├── profile/
  │   │   └── profile_screen.dart
  │   ├── messages/
  │   │   ├── conversations_screen.dart
  │   │   └── chat_screen.dart
  │   └── map/
  │       └── map_screen.dart
  ├── widgets/
  │   └── property_card.dart
  ├── services/
  │   └── api_service.dart
  └── utils/
      └── constants.dart
```

3. **Remplacer le fichier `pubspec.yaml`** avec celui fourni

4. **Installer les dépendances**
```bash
flutter pub get
```

5. **Configuration Google Maps** (Important!)

#### Pour Android :
Ajoutez votre clé API Google Maps dans `android/app/src/main/AndroidManifest.xml` :
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="VOTRE_CLE_API_GOOGLE_MAPS"/>
    </application>
</manifest>
```

#### Pour iOS :
Ajoutez votre clé API dans `ios/Runner/AppDelegate.swift` :
```swift
import GoogleMaps

GMSServices.provideAPIKey("VOTRE_CLE_API_GOOGLE_MAPS")
```

6. **Créer le dossier assets**
```bash
mkdir -p assets/images
mkdir -p assets/icons
```

7. **Lancer l'application**
```bash
flutter run
```

## 📱 Fonctionnalités

### ✅ Implémentées (avec données mockées)

- **Authentification**
  - Inscription
  - Connexion
  - Déconnexion

- **Recherche de biens**
  - Liste des propriétés
  - Filtres (ville, type, prix, nombre de pièces)
  - Recherche avancée

- **Détails d'une propriété**
  - Photos (carousel)
  - Informations détaillées
  - Localisation
  - Coordonnées du propriétaire

- **Publication d'annonce**
  - Formulaire complet
  - Upload de photos
  - Validation des données

- **Favoris**
  - Ajouter/Retirer des favoris
  - Liste des favoris

- **Messagerie**
  - Liste des conversations
  - Chat en temps réel
  - Badge de messages non lus
  - Historique des messages

- **Carte interactive**
  - Visualisation des biens sur Google Maps
  - Marqueurs colorés par type de transaction
  - Popup d'information

- **Profil utilisateur**
  - Affichage des informations
  - Déconnexion

### 🔄 À connecter au Backend

Pour connecter l'application au backend :

1. Modifier `utils/constants.dart` :
```dart
static const String apiBaseUrl = 'http://VOTRE_IP:3000/api';
```

2. Dans les providers, remplacer les appels mockés par :
```dart
final apiService = ApiService();
final data = await apiService.getProperties();
```

## 🔧 Configuration

### Changer l'URL du Backend

Fichier : `lib/utils/constants.dart`
```dart
static const String apiBaseUrl = 'http://localhost:3000/api';
```

### Permissions requises

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Nous avons besoin de votre localisation pour afficher les biens à proximité</string>
<key>NSCameraUsageDescription</key>
<string>Nous avons besoin d'accéder à votre appareil photo pour prendre des photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Nous avons besoin d'accéder à vos photos pour les annonces</string>
```

## 🎨 Thème et Design

L'application utilise Material Design 3 avec :
- Couleur principale : Bleu (#2196F3)
- Police : Poppins (Google Fonts)
- Mode clair uniquement (mode sombre à implémenter)

## 📦 Dépendances principales

- `provider` : State management
- `google_maps_flutter` : Cartes
- `image_picker` : Sélection d'images
- `cached_network_image` : Cache d'images
- `http` : Requêtes HTTP
- `shared_preferences` : Stockage local
- `google_fonts` : Polices personnalisées

## 🧪 Tests

Pour lancer les tests :
```bash
flutter test
```

## 📱 Build APK/IPA

### Android
```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🐛 Problèmes courants

### Erreur Google Maps
- Vérifiez que votre clé API est correcte
- Assurez-vous que l'API Google Maps est activée dans la console Google Cloud

### Erreur de build
```bash
flutter clean
flutter pub get
flutter run
```

### Erreur de permissions
- Vérifiez les permissions dans AndroidManifest.xml et Info.plist

## 📝 TODO / Améliorations futures

- [ ] Intégrer avec le backend réel
- [ ] Implémenter la messagerie entre utilisateurs
- [ ] Ajouter les notifications push
- [ ] Implémenter la géolocalisation en temps réel
- [ ] Ajouter un mode sombre
- [ ] Améliorer la gestion des images (compression, upload multiple)
- [ ] Ajouter des tests unitaires et d'intégration
- [ ] Internationalisation (i18n)
- [ ] Animations et transitions

## 👥 Auteurs

Projet développé dans le cadre du Mini Projet Défi - Application Mobile Services Immobilier

## 📄 Licence

Ce projet est développé à des fins éducatives.