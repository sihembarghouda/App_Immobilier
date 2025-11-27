# Guide de Seeding des Propriétés

Ce document explique comment peupler la base de données avec des propriétés diversifiées.

## Prérequis

- Backend configuré et démarré
- PostgreSQL en cours d'exécution
- Base de données créée avec les migrations appliquées

## Exécution du Seeding

### 1. Seeding Standard (300 propriétés)

```bash
cd backend
node src/database/seed_diverse_properties.js
```

### 2. Seeding Personnalisé (nombre spécifique)

```bash
cd backend
node src/database/seed_diverse_properties.js 500
```

Cela créera 500 propriétés au lieu de 300.

## Distribution Géographique

Le script génère des propriétés dans 12 villes tunisiennes:

- **Tunis** (36.8065, 10.1815)
- **Sfax** (34.7406, 10.7603)
- **Sousse** (35.8256, 10.6369)
- **Kairouan** (35.6781, 10.0963)
- **Bizerte** (37.2746, 9.8739)
- **Gabès** (33.8815, 10.0982)
- **Ariana** (36.8625, 10.1956)
- **Nabeul** (36.4561, 10.7356)
- **La Marsa** (36.8781, 10.3247)
- **Hammamet** (36.3997, 10.6167)
- **Monastir** (35.7770, 10.8261)
- **Ben Arous** (36.7540, 10.2189)

## Types de Propriétés

Le script génère 4 types de biens:

### Appartement
- Surface: 64-96 m²
- Pièces: 2-5
- Prix vente: ~150,000 TND
- Prix location: ~800 TND/mois

### Maison
- Surface: 120-180 m²
- Pièces: 4-8
- Prix vente: ~250,000 TND
- Prix location: ~1,200 TND/mois

### Villa
- Surface: 240-360 m²
- Pièces: 6-12
- Prix vente: ~500,000 TND
- Prix location: ~2,500 TND/mois

### Studio
- Surface: 24-36 m²
- Pièces: 1
- Prix vente: ~80,000 TND
- Prix location: ~500 TND/mois

## Caractéristiques Générées

Pour chaque propriété:

- **Titre**: Généré automatiquement (ex: "Appartement à vendre - Tunis")
- **Description**: Texte français descriptif selon le type
- **Prix**: Varie de ±25% autour du prix de base
- **Surface**: Varie de ±20% autour de la surface de base
- **Chambres**: ~60% du nombre de pièces (sauf studio = 0)
- **Salles de bain**: ~30% du nombre de pièces (minimum 1)
- **Coordonnées**: Variation de ±0.1° autour du centre-ville
- **Images**: 1-3 images placeholder (Unsplash)
- **Propriétaire**: Assigné aléatoirement parmi les utilisateurs existants

## Sortie du Script

```
🌱 Starting to seed 300 diverse properties...
✅ Progress: 50/300 properties created
✅ Progress: 100/300 properties created
✅ Progress: 150/300 properties created
✅ Progress: 200/300 properties created
✅ Progress: 250/300 properties created
✅ Progress: 300/300 properties created

✅ Seeding completed!
   Successfully created: 300 properties
   Errors: 0
   Distribution by city:
      Ariana - apartment (rent): 3
      Ariana - apartment (sale): 4
      Ariana - house (rent): 2
      ...
```

## Nettoyage des Données

Pour supprimer toutes les propriétés générées:

```sql
-- Connexion à PostgreSQL
psql -U postgres -d immobilier_db

-- Suppression des propriétés
DELETE FROM properties WHERE created_at > '2024-01-01';

-- Ou suppression totale
TRUNCATE TABLE properties CASCADE;
```

## Intégration avec l'Application

Après le seeding:

1. **Frontend Flutter**: Les propriétés apparaîtront sur la carte
2. **Zoom adaptatif**: Le sampling automatique s'active selon le niveau de zoom
3. **Filtres**: Les filtres par type/transaction/prix fonctionnent normalement
4. **Recherche**: Les propriétés sont cherchables par ville/titre

## Dépannage

### Erreur: "No users found"

Le script crée automatiquement un utilisateur par défaut si aucun n'existe:

```javascript
{
  name: 'Default Owner',
  email: 'owner@homefinder.com',
  role: 'seller',
  phone: '+216 98 000 000'
}
```

### Erreur: "Connection refused"

Vérifiez que PostgreSQL est démarré et que les credentials dans `backend/src/config/database.js` sont corrects.

### Propriétés non visibles sur la carte

1. Vérifiez le niveau de zoom (zoom < 12 applique du sampling)
2. Vérifiez les filtres actifs dans l'interface
3. Inspectez les logs backend pour les erreurs API

## Performance

- **Création**: ~0.1 seconde par propriété
- **300 propriétés**: ~30 secondes
- **500 propriétés**: ~50 secondes
- **1000 propriétés**: ~100 secondes

## Notes

- Les images utilisent des placeholders Unsplash (nécessite connexion Internet)
- Les coordonnées sont réalistes mais légèrement randomisées
- Les prix varient pour un réalisme accru
- Les propriétés sont immédiatement visibles après le seeding
