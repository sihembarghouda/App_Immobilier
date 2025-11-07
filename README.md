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
