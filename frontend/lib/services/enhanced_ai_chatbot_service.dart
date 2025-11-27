class EnhancedAIChatbotService {
  // Questions suggérées pour guider le client
  static List<Map<String, String>> get suggestedQuestions => [
        {
          'category': 'Recherche',
          'question': 'Je cherche une maison familiale avec jardin',
          'icon': '🏠',
        },
        {
          'category': 'Recherche',
          'question': 'Montrez-moi des appartements modernes en centre-ville',
          'icon': '🏠',
        },
        {
          'category': 'Budget',
          'question':
              'Quelles propriétés sont disponibles pour moins de 200000 DT?',
          'icon': '💰',
        },
        {
          'category': 'Budget',
          'question': 'Puis-je trouver un bon appartement pour 150000 DT?',
          'icon': '💰',
        },
        {
          'category': 'Location',
          'question': 'Quels quartiers recommandez-vous pour les familles?',
          'icon': '📍',
        },
        {
          'category': 'Location',
          'question': 'Propriétés près du centre-ville',
          'icon': '📍',
        },
        {
          'category': 'Conseils',
          'question': 'Dois-je acheter ou louer?',
          'icon': '💡',
        },
        {
          'category': 'Conseils',
          'question': 'Quels sont les frais d\'achat d\'une maison?',
          'icon': '💡',
        },
        {
          'category': 'Financement',
          'question': 'Comment obtenir un prêt immobilier?',
          'icon': '🏦',
        },
        {
          'category': 'Financement',
          'question': 'Quel est mon budget d\'achat réaliste?',
          'icon': '🏦',
        },
      ];

  // Réponses détaillées enrichies
  static Map<String, dynamic> getEnhancedAnswer(String question) {
    return _getDetailedLocalResponse(question);
  }

  static Map<String, dynamic> _getDetailedLocalResponse(String question) {
    final lowerQuestion = question.toLowerCase();

    // Réponses sur l'achat vs location
    if (lowerQuestion.contains('acheter') || lowerQuestion.contains('louer')) {
      return {
        'answer': '''
🏠 **Acheter ou Louer - Guide Complet**

**Avantages d'Acheter:**
✅ Constitution d'un patrimoine
✅ Liberté de personnalisation
✅ Investissement à long terme
✅ Pas de loyer à payer
✅ Potentiel de plus-value

**Avantages de Louer:**
✅ Flexibilité géographique
✅ Pas de frais d'entretien majeurs
✅ Pas d'engagement à long terme
✅ Capital disponible pour investir ailleurs

**Conseil Personnalisé:**
- Si vous prévoyez rester > 5 ans → **Achetez**
- Si mobilité professionnelle → **Louez**
- Budget limité aujourd'hui → **Louez** puis achetez

**Questions à vous poser:**
1. Stabilité professionnelle et géographique?
2. Capacité d'emprunt?
3. Épargne disponible (apport 10-20%)?
4. Projets de vie à 5-10 ans?
        ''',
        'relatedQuestions': [
          'Comment calculer ma capacité d\'emprunt?',
          'Quels sont les frais d\'achat?',
          'Meilleures zones pour investir',
        ],
      };
    }

    // Réponses sur le budget
    if (lowerQuestion.contains('budget') || lowerQuestion.contains('prix')) {
      return {
        'answer': '''
💰 **Guide Budget Immobilier**

**Calcul de Capacité d'Achat:**
Revenus mensuels × 33% = Mensualité maximale
Sur 20 ans: ~120 mensualités
Sur 25 ans: ~150 mensualités

**Exemple:**
Revenus: 2000 DT/mois → Budget: 130,000-160,000 DT

**Frais à Prévoir:**
- Apport personnel: 10-20%
- Frais de notaire: 2-3%
- Frais d'agence: 2-5%
- Travaux: 5-10%

**Conseils:**
✓ Gardez une épargne de sécurité
✓ Comparez les banques
        ''',
        'relatedQuestions': [
          'Simulation de prêt',
          'Aides financières',
          'Propriétés dans mon budget',
        ],
      };
    }

    // Réponses sur les quartiers
    if (lowerQuestion.contains('quartier') || lowerQuestion.contains('zone')) {
      return {
        'answer': '''
📍 **Guide des Quartiers**

**Pour Familles:**
🏡 Jardins de Carthage - Calme, écoles
🏡 El Menzah - Résidentiel
🏡 Soukra - Sécurisé

**Pour Jeunes Actifs:**
🏙️ Centre-Ville - Dynamique
🏙️ Lac 1 & 2 - Moderne
🏙️ Marsa - Bord de mer

**Critères:**
- Proximité travail
- Écoles de qualité
- Transports
        ''',
        'relatedQuestions': [
          'Prix par quartier',
          'Transports',
          'Services',
        ],
      };
    }

    // Réponses sur les documents
    if (lowerQuestion.contains('document') ||
        lowerQuestion.contains('papier') ||
        lowerQuestion.contains('frais')) {
      return {
        'answer': '''
📋 **Documents Nécessaires**

**Pour l'Acheteur:**
- Carte d'identité
- Justificatif de domicile
- Justificatifs de revenus (3 mois)
- Relevés bancaires

**Pour le Prêt:**
- Attestation de travail
- Bulletins de salaire
- Justificatifs d'épargne

**Délais:**
- Accord de principe: 48h-1 semaine
- Offre de prêt: 2-4 semaines
- Signature: 3-4 mois
        ''',
        'relatedQuestions': [
          'Étapes de l\'achat',
          'Rôle du notaire',
          'Assurances',
        ],
      };
    }

    // Recherche de propriété
    if (lowerQuestion.contains('cherche') ||
        lowerQuestion.contains('trouver') ||
        lowerQuestion.contains('maison') ||
        lowerQuestion.contains('appartement') ||
        lowerQuestion.contains('villa')) {
      return {
        'answer': '''
🔍 **Guide de Recherche**

**Étapes:**
1. Définir critères (budget, type, localisation)
2. Visiter plusieurs propriétés (5-10)
3. Comparer les quartiers
4. Négocier (marge: 5-15%)

💡 **Astuce:** Visitez à différents moments de la journée!
        ''',
        'relatedQuestions': [
          'Comment négocier?',
          'Checklist de visite',
          'Éviter les arnaques',
        ],
      };
    }

    // Réponse par défaut
    return {
      'answer': '''
🏠 **Assistant Immobilier Personnel**

Je peux vous aider avec:

**🔍 Recherche:** Trouver votre bien idéal
**💰 Finance:** Calculer votre budget
**📍 Quartiers:** Meilleurs zones
**📚 Conseils:** Guide d'achat complet
**💡 Décision:** Acheter vs Louer

**Exemples de questions:**
- "Je cherche une maison avec jardin"
- "Quel est mon budget réaliste?"
- "Dois-je acheter ou louer?"
- "Quels documents pour acheter?"
- "Meilleurs quartiers pour familles?"

**Posez-moi votre question! 😊**
      ''',
      'relatedQuestions': [
        'Rechercher une propriété',
        'Calculer mon budget',
        'Guides et conseils',
      ],
    };
  }
}
