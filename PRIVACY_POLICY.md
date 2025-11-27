# Politique de Confidentialité - ImmoTunisie

**Date d'entrée en vigueur :** 26 novembre 2025  
**Dernière mise à jour :** 26 novembre 2025

## 1. Introduction

ImmoTunisie ("nous", "notre", "l'Application") respecte votre vie privée et s'engage à protéger vos données personnelles. Cette politique de confidentialité explique comment nous collectons, utilisons, stockons et protégeons vos informations lorsque vous utilisez notre application mobile.

## 2. Informations que nous collectons

### 2.1 Informations fournies directement
- **Compte utilisateur** : Nom, email, numéro de téléphone
- **Photo de profil** : Image téléchargée volontairement
- **Annonces immobilières** : Titre, description, prix, photos, adresse
- **Messages** : Communications avec autres utilisateurs

### 2.2 Informations collectées automatiquement
- **Géolocalisation** : Position GPS pour rechercher des biens à proximité (avec votre autorisation)
- **Photos** : Accès à votre galerie pour publier des annonces (avec votre autorisation)
- **Données techniques** : Type d'appareil, système d'exploitation, version de l'application

## 3. Utilisation de vos données

Nous utilisons vos données pour :
- **Fonctionnement du service** : Créer et gérer votre compte
- **Annonces immobilières** : Publier et afficher vos propriétés
- **Recherche géographique** : Afficher les biens près de vous sur la carte
- **Messagerie** : Faciliter la communication entre acheteurs et vendeurs
- **Assistant IA** : Fournir des recommandations personnalisées
- **Sécurité** : Protéger contre la fraude et les abus

## 4. Partage de données

Nous **NE vendons JAMAIS** vos données personnelles.

Vos données sont partagées uniquement :
- **Avec d'autres utilisateurs** : Votre nom et contact sont visibles sur vos annonces publiques
- **Services tiers techniques** :
  - Hébergement backend (serveur Node.js)
  - Base de données PostgreSQL sécurisée
  - OpenStreetMap pour les cartes (pas Google Maps)
  - OpenAI pour l'assistant IA (données anonymisées)

## 5. Permissions de l'application

L'application demande les permissions suivantes :

| Permission | Utilisation | Obligatoire |
|------------|-------------|-------------|
| **INTERNET** | Communication avec le serveur | Oui |
| **Localisation (GPS)** | Recherche de biens à proximité | Non (optionnel) |
| **Appareil photo** | Photo de profil | Non (optionnel) |
| **Galerie photos** | Upload d'images d'annonces | Non (optionnel) |

Vous pouvez refuser ces permissions dans les paramètres de votre appareil. Certaines fonctionnalités seront alors limitées.

## 6. Stockage et sécurité

- **Chiffrement** : Communications HTTPS entre l'app et le serveur
- **Mots de passe** : Hashés avec bcrypt (jamais stockés en clair)
- **Localisation** : PostgreSQL hébergé en Europe (RGPD compliant)
- **Durée de conservation** : Données conservées tant que votre compte est actif

## 7. Vos droits (RGPD)

Vous avez le droit de :
- **Accéder** à vos données personnelles
- **Rectifier** des informations incorrectes
- **Supprimer** votre compte et toutes vos données
- **Exporter** vos données dans un format lisible
- **Vous opposer** au traitement de certaines données

**Pour exercer vos droits :** Contactez-nous à [votre-email@example.com]

## 8. Données des mineurs

L'application est destinée aux personnes de **18 ans et plus**. Nous ne collectons pas intentionnellement de données d'enfants de moins de 13 ans.

## 9. Cookies et trackers

Nous **n'utilisons PAS** :
- ❌ Cookies de publicité
- ❌ Trackers tiers (Google Analytics, Facebook Pixel, etc.)
- ❌ Outils de profilage marketing

Nous utilisons uniquement :
- ✅ Token JWT pour l'authentification (stocké localement sur votre appareil)

## 10. Modifications de cette politique

Nous pouvons mettre à jour cette politique de confidentialité. Vous serez notifié des changements importants via l'application ou par email.

## 11. Contact

Pour toute question concernant cette politique :

**Email :** [votre-email@example.com]  
**Adresse :** [Votre adresse en Tunisie]  
**Téléphone :** [Votre numéro]

## 12. Juridiction

Cette politique est régie par les lois tunisiennes et les réglementations de l'Union Européenne (RGPD).

---

**Dernière révision :** 26 novembre 2025  
**Version :** 1.0
