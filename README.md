# 📱 Application Immobilier - Frontend Flutter

Application mobile cross-platform pour la recherche, consultation et publication d'annonces immobilières.

## 📋 Table des matières

- [Aperçu](#aperçu)
- [Fonctionnalités](#fonctionnalités)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Lancement](#lancement)
- [Structure du projet](#structure-du-projet)
- [Architecture](#architecture)
- [Dépendances](#dépendances)
- [Captures d'écran](#captures-décran)
- [Guide d'utilisation](#guide-dutilisation)
- [Troubleshooting](#troubleshooting)
- [Contribution](#contribution)

---

## 🎯 Aperçu

Application mobile développée avec Flutter permettant de :
- Rechercher des biens immobiliers
- Publier des annonces
- Gérer ses favoris
- Communiquer avec les propriétaires
- Visualiser les biens sur une carte

**Plateforme** : Android & iOS  
**Framework** : Flutter 3.0+  
**Langage** : Dart

---

## ✨ Fonctionnalités

### 🔐 Authentification
- [x] Inscription avec email et mot de passe
- [x] Connexion sécurisée
- [x] Persistance de session
- [x] Déconnexion avec confirmation

### 🏠 Propriétés
- [x] Liste des annonces disponibles
- [x] Détails complets (photos, prix, surface, etc.)
- [x] Recherche avancée avec filtres :
  - Ville
  - Type de bien (appartement, maison, villa, studio)
  - Type de transaction (vente, location)
  - Fourchette de prix
  - Nombre de pièces
  - Surface
- [x] Publication d'annonces
- [x] Upload de photos multiples

### ⭐ Favoris
- [x] Ajouter/Retirer des favoris
- [x] Liste de tous les favoris
- [x] Synchronisation en temps réel

### 💬 Messagerie
- [x] Liste des conversations
- [x] Chat en temps réel
- [x] Badge de messages non lus
- [x] Historique des messages
- [x] Notifications de nouveaux messages

### 🗺️ Carte & Géolocalisation
- [x] Visualisation sur Google Maps
- [x] Marqueurs pour chaque propriété
- [x] Popup d'information
- [x] Navigation vers détails depuis la carte

### 👤 Profil
- [x] Affichage des informations utilisateur
- [x] Formulaire de connexion/inscription intégré
- [x] Gestion du compte
- [x] Déconnexion sécurisée

---

## 📦 Prérequis

### Logiciels requis

- **Flutter SDK** (>= 3.0.0) - [Installation](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (>= 3.0.0) - Inclus avec Flutter
- **Android Studio** ou **VS Code** avec extensions Flutter
- **Git** pour cloner le projet

### Pour Android
- Android SDK (API 21+)
- Émulateur Android ou appareil physique

### Pour iOS (Mac uniquement)
- Xcode (>= 14.0)
- CocoaPods
- Simulateur iOS ou appareil physique

---

## 🚀 Installation

### 1. Installer Flutter

```bash
# Vérifier que Flutter est installé
flutter --version

# Si non installé, suivre le guide officiel
# https://docs.flutter.dev/get-started/install
```

### 2. Cloner le projet

```bash
git clone https://github.com/votre-repo/immobilier-app.git
cd immobilier-app
```

### 3. Installer les dépendances

```bash
flutter pub get
```

### 4. Vérifier l'installation

```bash
flutter doctor
```

Corrigez les éventuels problèmes signalés.

---

## ⚙️ Configuration

### 1. Configuration de base

Le fichier `lib/utils/constants.dart` contient les configurations :

```dart
class AppConstants {
  // URL du backend API
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api';
  
  // Autres configurations...
}
```

### 2. Configuration selon votre environnement

#### 📱 Émulateur Android
```dart
static const String apiBaseUrl = 'http://10.0.2.2:3000/api';
```

#### 📱 Émulateur iOS
```dart
static const String apiBaseUrl = 'http://localhost:3000/api';
```

#### 📱 Appareil physique
```dart
static const String apiBaseUrl = 'http://VOTRE_IP_LOCALE:3000/api';
```

**Trouver votre IP locale** :
```bash
# Linux/Mac
ifconfig | grep "inet "

# Windows
ipconfig
```

### 3. Configuration Google Maps (Important !)

#### Android
Éditez `android/app/src/main/AndroidManifest.xml` :

```xml
<manifest>
    <application>
        <!-- Ajoutez votre clé API Google Maps -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="VOTRE_CLE_API_GOOGLE_MAPS"/>
    </application>
</manifest>
```

#### iOS
Éditez `ios/Runner/AppDelegate.swift` :

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("VOTRE_CLE_API_GOOGLE_MAPS")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Obtenir une clé API Google Maps** :
1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un projet
3. Activez l'API Google Maps
4. Créez des credentials (clé API)

### 4. Permissions nécessaires

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Pour autoriser HTTP en développement -->
<application
    android:usesCleartextTraffic="true">
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Nous avons besoin de votre localisation pour afficher les biens à proximité</string>

<key>NSCameraUsageDescription</key>
<string>Nous avons besoin d'accéder à votre appareil photo pour prendre des photos</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Nous avons besoin d'accéder à vos photos pour les annonces</string>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 5. Créer le dossier assets

```bash
mkdir -p assets/images
mkdir -p assets/icons
```

---

## 🎮 Lancement

### Mode Debug

```bash
# Lister les appareils connectés
flutter devices

# Lancer sur un appareil spécifique
flutter run -d <device_id>

# Lancer en mode debug (par défaut)
flutter run
```

### Mode Release (optimisé)

```bash
flutter run --release
```

### Hot Reload

Pendant que l'app tourne :
- Appuyez sur `r` pour hot reload
- Appuyez sur `R` pour hot restart
- Appuyez sur `q` pour quitter

---

## 📁 Structure du projet

```
lib/
├── main.dart                          # Point d'entrée
│
├── models/                            # Modèles de données
│   ├── user.dart                      # Modèle Utilisateur
│   ├── property.dart                  # Modèle Propriété
│   └── message.dart                   # Modèle Message
│
├── providers/                         # State Management (Provider)
│   ├── auth_provider.dart             # Gestion authentification
│   ├── property_provider.dart         # Gestion propriétés
│   └── message_provider.dart          # Gestion messages
│
├── screens/                           # Écrans de l'application
│   ├── auth/
│   │   ├── login_screen.dart          # Écran de connexion
│   │   └── register_screen.dart       # Écran d'inscription
│   ├── home/
│   │   └── home_screen.dart           # Écran d'accueil
│   ├── property/
│   │   ├── property_detail_screen.dart # Détails propriété
│   │   └── add_property_screen.dart    # Ajouter une propriété
│   ├── search/
│   │   └── search_screen.dart         # Recherche avancée
│   ├── favorites/
│   │   └── favorites_screen.dart      # Liste des favoris
│   ├── messages/
│   │   ├── conversations_screen.dart   # Liste conversations
│   │   └── chat_screen.dart           # Chat privé
│   ├── profile/
│   │   └── profile_screen.dart        # Profil utilisateur
│   └── map/
│       └── map_screen.dart            # Carte Google Maps
│
├── widgets/                           # Widgets réutilisables
│   └── property_card.dart             # Carte d'annonce
│
├── services/                          # Services externes
│   └── api_service.dart               # Appels API
│
└── utils/                             # Utilitaires
    └── constants.dart                 # Constantes de l'app
```

---

## 🏗️ Architecture

### Pattern : Provider (State Management)

L'application utilise le pattern **Provider** pour la gestion d'état :

```
┌──────────────┐
│   Widgets    │ ← Observer les changements
└──────┬───────┘
       │
       ↓
┌──────────────┐
│  Providers   │ ← Gère l'état et la logique
└──────┬───────┘
       │
       ↓
┌──────────────┐
│   Models     │ ← Représentation des données
└──────┬───────┘
       │
       ↓
┌──────────────┐
│ API Service  │ ← Communication backend
└──────────────┘
```

### Flux de données

1. **User Action** → Widget déclenche une action
2. **Provider** → Traite la logique métier
3. **API Service** → Communique avec le backend
4. **Model** → Parse la réponse JSON
5. **Provider** → Met à jour l'état
6. **Widget** → Se reconstruit automatiquement

---

## 📚 Dépendances

### Principales dépendances (`pubspec.yaml`)

| Package | Version | Usage |
|---------|---------|-------|
| **provider** | ^6.1.1 | State management |
| **http** | ^1.2.0 | Requêtes HTTP |
| **google_maps_flutter** | ^2.5.3 | Cartes Google Maps |
| **image_picker** | ^1.0.7 | Sélection d'images |
| **cached_network_image** | ^3.3.1 | Cache d'images |
| **shared_preferences** | ^2.2.2 | Stockage local |
| **google_fonts** | ^6.1.0 | Polices Google |
| **intl** | ^0.19.0 | Internationalisation |

### Installation d'une dépendance

```bash
# Ajouter une dépendance
flutter pub add nom_package

# Mettre à jour les dépendances
flutter pub upgrade

# Supprimer le cache
flutter pub cache clean
```

---

## 📸 Captures d'écran

### Écran de connexion
![Login](screenshots/login.png)

### Liste des propriétés
![Properties](screenshots/properties.png)

### Détails d'une propriété
![Details](screenshots/details.png)

### Carte interactive
![Map](screenshots/map.png)

### Messagerie
![Messages](screenshots/messages.png)

---

## 📖 Guide d'utilisation

### 1. Première utilisation

#### Avec données de test (Backend lancé)
1. Lancez l'application
2. Cliquez sur l'onglet **Profil**
3. Utilisez les credentials :
   - **Email** : `john@example.com`
   - **Password** : `password123`

#### Sans backend (Mode démo)
L'application fonctionne avec des données mockées par défaut.

### 2. Navigation

**Bottom Navigation Bar** :
- 🏠 **Accueil** : Liste des propriétés
- 🔍 **Recherche** : Filtres avancés
- ➕ **Publier** : Ajouter une annonce
- 💬 **Messages** : Conversations
- ⭐ **Favoris** : Propriétés sauvegardées
- 👤 **Profil** : Compte utilisateur

### 3. Rechercher un bien

1. Onglet **Recherche**
2. Remplir les filtres souhaités :
   - Ville
   - Type de bien
   - Prix min/max
   - Nombre de pièces
3. Cliquer sur **Rechercher**

### 4. Publier une annonce

1. Connectez-vous
2. Onglet **Publier**
3. Remplir le formulaire
4. Ajouter des photos (optionnel)
5. **Publier l'annonce**

### 5. Ajouter aux favoris

1. Sur une carte de propriété, cliquez sur ❤️
2. Ou dans les détails, cliquez sur l'icône favori
3. Retrouvez tous vos favoris dans l'onglet **Favoris**

### 6. Contacter un propriétaire

1. Ouvrir les détails d'une propriété
2. Cliquer sur **Appeler** (lance l'app téléphone)
3. Ou cliquer sur **Message** (ouvre le chat)

---

## 🐛 Troubleshooting

### Problème : L'application ne se lance pas

```bash
# Nettoyer le projet
flutter clean
flutter pub get

# Réinstaller les pods (iOS uniquement)
cd ios && pod install && cd ..

# Relancer
flutter run
```

### Problème : Erreur de build Android

```bash
# Accepter les licences
flutter doctor --android-licenses

# Rebuild
cd android
./gradlew clean
cd ..
flutter run
```

### Problème : Google Maps ne s'affiche pas

**Solution** :
1. Vérifiez que la clé API est correcte
2. Vérifiez que l'API Maps est activée dans Google Cloud
3. Vérifiez les permissions de localisation

### Problème : Erreur de connexion API

```
SocketException: Connection refused
```

**Solutions** :
1. Vérifiez que le backend est lancé
2. Vérifiez l'URL dans `constants.dart`
3. Pour Android émulateur : utilisez `10.0.2.2` au lieu de `localhost`
4. Pour appareil physique : utilisez votre IP locale

### Problème : Upload d'images ne fonctionne pas

**Solutions** :
1. Vérifiez les permissions dans `AndroidManifest.xml` et `Info.plist`
2. Sur émulateur : utilisez des images de la galerie de l'émulateur
3. Sur appareil : autorisez les permissions quand demandé

---

## 🔨 Build pour production

### Android APK

```bash
flutter build apk --release
```

Le fichier APK sera dans : `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (pour Google Play)

```bash
flutter build appbundle --release
```

### iOS (Mac uniquement)

```bash
flutter build ios --release
```

Puis ouvrir dans Xcode pour l'upload sur App Store.

---

## 🧪 Tests

### Lancer les tests

```bash
# Tous les tests
flutter test

# Tests spécifiques
flutter test test/unit/auth_test.dart

# Avec coverage
flutter test --coverage
```

### Tests à créer

- [ ] Tests unitaires des providers
- [ ] Tests unitaires des models
- [ ] Tests d'intégration
- [ ] Tests de widgets

---

## 📊 Performance

### Analyser la performance

```bash
flutter run --profile

# Puis dans l'app, appuyez sur 'P' pour voir le performance overlay
```

### Optimisations appliquées

- ✅ Lazy loading des images
- ✅ Cache des images réseau
- ✅ Pagination (à implémenter côté backend)
- ✅ Debounce sur la recherche

---

## 🚀 Prochaines améliorations

### Court terme
- [ ] Tests unitaires complets
- [ ] Mode sombre
- [ ] Multi-langue (FR/EN/AR)
- [ ] Pagination des listes
- [ ] Pull-to-refresh amélioré

### Moyen terme
- [ ] Notifications push (Firebase)
- [ ] Chat temps réel (WebSocket)
- [ ] Stories de propriétés
- [ ] Filtres sauvegardés
- [ ] Partage d'annonces

### Long terme
- [ ] Visite virtuelle 360°
- [ ] Recommandations IA
- [ ] Calculateur de prêt
- [ ] Comparateur de biens
- [ ] Mode hors-ligne

---
# Backend API - Application Immobilier

API REST pour l'application mobile de services immobiliers.

## 🛠️ Technologies

- **Node.js** + **Express.js**
- **PostgreSQL** (Base de données)
- **JWT** (Authentification)
- **Bcrypt** (Hachage de mots de passe)
- **Multer** (Upload de fichiers)

## 📁 Structure du projet

```
backend/
├── server.js                 # Point d'entrée
├── package.json
├── .env                      # Configuration (ne pas commit!)
├── uploads/                  # Dossier des images uploadées
└── src/
    ├── config/
    │   ├── database.js       # Configuration PostgreSQL
    │   └── multer.js         # Configuration upload
    ├── controllers/
    │   ├── auth.controller.js
    │   ├── property.controller.js
    │   ├── favorite.controller.js
    │   ├── message.controller.js
    │   └── upload.controller.js
    ├── middleware/
    │   ├── auth.middleware.js
    │   └── validation.middleware.js
    ├── routes/
    │   ├── auth.routes.js
    │   ├── property.routes.js
    │   ├── favorite.routes.js
    │   ├── message.routes.js
    │   └── upload.routes.js
    └── database/
        ├── schema.sql        # Schéma SQL
        └── migrate.js        # Script de migration
```

## 🚀 Installation

### 1. Prérequis

- **Node.js** (v16 ou supérieur)
- **PostgreSQL** (v12 ou supérieur)
- **npm** ou **yarn**

### 2. Installation de PostgreSQL

#### Sur Ubuntu/Debian :
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### Sur macOS (avec Homebrew) :
```bash
brew install postgresql@14
brew services start postgresql@14
```

#### Sur Windows :
Téléchargez l'installateur depuis [postgresql.org](https://www.postgresql.org/download/windows/)

### 3. Créer un utilisateur PostgreSQL (optionnel)

```bash
# Se connecter à PostgreSQL
sudo -u postgres psql

# Créer un utilisateur
CREATE USER immobilier_user WITH PASSWORD 'your_password';
ALTER USER immobilier_user CREATEDB;

# Quitter
\q
```

### 4. Installer les dépendances du projet

```bash
cd backend
npm install
```

### 5. Configuration (.env)

Créez un fichier `.env` à la racine du projet backend :

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=immobilier_db
DB_USER=postgres
DB_PASSWORD=votre_mot_de_passe

# JWT Configuration
JWT_SECRET=votre_secret_jwt_tres_securise
JWT_EXPIRES_IN=7d

# File Upload
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=5242880

# CORS
CORS_ORIGIN=http://localhost:8080
```

⚠️ **Important** : Changez `JWT_SECRET` et `DB_PASSWORD` !

### 6. Initialiser la base de données

```bash
npm run migrate
```

Ce script va :
- ✅ Créer la base de données
- ✅ Créer toutes les tables
- ✅ Créer les index
- ✅ Insérer des données de test

### 7. Lancer le serveur

**Mode développement** (avec auto-reload) :
```bash
npm run dev
```

**Mode production** :
```bash
npm start
```

Le serveur démarre sur `http://localhost:3000`

## 📡 API Endpoints

### **Authentication** (`/api/auth`)

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| POST | `/register` | Inscription | ❌ |
| POST | `/login` | Connexion | ❌ |
| GET | `/me` | Utilisateur actuel | ✅ |

### **Properties** (`/api/properties`)

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| GET | `/` | Liste des propriétés (avec filtres) | ❌ |
| GET | `/:id` | Détails d'une propriété | ❌ |
| POST | `/` | Créer une propriété | ✅ |
| PUT | `/:id` | Modifier une propriété | ✅ |
| DELETE | `/:id` | Supprimer une propriété | ✅ |

**Filtres disponibles** :
- `city` : Ville
- `type` : Type (apartment, house, villa, studio)
- `transaction_type` : Type de transaction (sale, rent)
- `min_price` / `max_price` : Fourchette de prix
- `min_rooms` / `max_rooms` : Nombre de pièces
- `min_surface` / `max_surface` : Surface

### **Favorites** (`/api/favorites`)

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| GET | `/` | Liste des favoris | ✅ |
| POST | `/` | Ajouter aux favoris | ✅ |
| DELETE | `/:propertyId` | Retirer des favoris | ✅ |

### **Messages** (`/api/messages`)

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| GET | `/conversations` | Liste des conversations | ✅ |
| GET | `/:userId` | Messages avec un utilisateur | ✅ |
| POST | `/` | Envoyer un message | ✅ |
| PUT | `/:userId/read` | Marquer comme lu | ✅ |

### **Upload** (`/api/upload`)

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| POST | `/` | Upload une image | ✅ |
| POST | `/multiple` | Upload plusieurs images | ✅ |

## 🔐 Authentification

L'API utilise **JWT (JSON Web Token)** pour l'authentification.

### Comment s'authentifier :

1. **Login** : `POST /api/auth/login`
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

2. **Récupérer le token** dans la réponse :
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": { ... }
  }
}
```

3. **Utiliser le token** dans les requêtes protégées :
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 📝 Exemples de requêtes

### Inscription
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123",
    "phone": "+216 98 765 432"
  }'
```

### Connexion
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

### Récupérer les propriétés
```bash
curl http://localhost:3000/api/properties
```

### Rechercher des propriétés
```bash
curl "http://localhost:3000/api/properties?city=Tunis&type=apartment&min_price=100000&max_price=300000"
```

### Créer une propriété
```bash
curl -X POST http://localhost:3000/api/properties \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Bel appartement",
    "description": "Très lumineux",
    "type": "apartment",
    "transaction_type": "sale",
    "price": 200000,
    "surface": 100,
    "rooms": 4,
    "bedrooms": 3,
    "bathrooms": 2,
    "address": "Rue exemple",
    "city": "Tunis",
    "latitude": 36.8065,
    "longitude": 10.1815,
    "images": ["url1", "url2"]
  }'
```

### Upload une image
```bash
curl -X POST http://localhost:3000/api/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@/path/to/image.jpg"
```

## 🔍 Test avec Postman

Importez cette collection dans Postman :

1. Créer une nouvelle collection "Immobilier API"
2. Ajouter une variable d'environnement `base_url` = `http://localhost:3000/api`
3. Ajouter une variable `token` pour stocker le JWT
4. Créer les requêtes pour chaque endpoint

## 🗄️ Base de données

### Schéma

**users**
- id, email, password, name, phone, avatar, created_at, updated_at

**properties**
- id, title, description, type, transaction_type, price, surface, rooms, bedrooms, bathrooms, address, city, latitude, longitude, images[], owner_id, created_at, updated_at

**favorites**
- id, user_id, property_id, created_at

**messages**
- id, sender_id, receiver_id, content, property_id, is_read, created_at, updated_at

### Connexion directe à PostgreSQL

```bash
psql -U postgres -d immobilier_db
```

Commandes utiles :
```sql
-- Lister les tables
\dt

-- Voir la structure d'une table
\d properties

-- Compter les propriétés
SELECT COUNT(*) FROM properties;

-- Voir tous les utilisateurs
SELECT id, name, email FROM users;
```

## 🧪 Tests

```bash
# Test de santé
curl http://localhost:3000/health

# Réponse attendue
{
  "status": "OK",
  "message": "Server is running",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

## 🐛 Dépannage

### Erreur de connexion PostgreSQL

```
❌ Database connection failed: password authentication failed
```

**Solution** : Vérifiez vos credentials dans `.env`

### Port déjà utilisé

```
Error: listen EADDRINUSE: address already in use :::3000
```

**Solution** : Changez le port dans `.env` ou tuez le processus :
```bash
# Linux/Mac
lsof -ti:3000 | xargs kill -9

# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### Uploads ne fonctionnent pas

**Solution** : Créez le dossier manuellement :
```bash
mkdir uploads
chmod 755 uploads
```

## 📊 Données de test

Après la migration, vous aurez :

**Utilisateurs** :
- john@example.com / password123
- ahmed@example.com / password123
- fatma@example.com / password123

**5 propriétés** de test
**Quelques messages** de test

## 🚀 Déploiement

### Sur Heroku

1. Créer une app Heroku
2. Ajouter PostgreSQL addon
3. Configurer les variables d'environnement
4. Déployer

```bash
heroku create mon-app-immobilier
heroku addons:create heroku-postgresql:mini
heroku config:set JWT_SECRET=votre_secret
git push heroku main
```

### Sur VPS (Ubuntu)

```bash
# Installer Node.js et PostgreSQL
# Cloner le repo
# Configurer .env
# Installer PM2
npm install -g pm2
pm2 start server.js --name immobilier-api
pm2 save
pm2 startup
```

## 📄 Licence

Ce projet est développé à des fins éducatives.
