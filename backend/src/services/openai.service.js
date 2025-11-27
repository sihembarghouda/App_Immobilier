// services/openai.service.js
const https = require('https');

class OpenAIService {
  constructor() {
    this.apiKey = process.env.OPENAI_API_KEY;
    this.model = process.env.OPENAI_MODEL || 'gpt-4';
  }

  async chat(messages, temperature = 0.7) {
    if (!this.apiKey) {
      throw new Error('OPENAI_API_KEY not configured');
    }

    const data = JSON.stringify({
      model: this.model,
      messages: messages,
      temperature: temperature,
      max_tokens: 1000
    });

    const options = {
      hostname: 'api.openai.com',
      path: '/v1/chat/completions',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Length': data.length
      }
    };

    return new Promise((resolve, reject) => {
      const req = https.request(options, (res) => {
        let body = '';

        res.on('data', (chunk) => {
          body += chunk;
        });

        res.on('end', () => {
          try {
            const response = JSON.parse(body);
            
            if (response.error) {
              reject(new Error(response.error.message));
            } else {
              resolve(response.choices[0].message.content);
            }
          } catch (error) {
            reject(error);
          }
        });
      });

      req.on('error', (error) => {
        reject(error);
      });

      req.write(data);
      req.end();
    });
  }

  // Assistant immobilier avec contexte
  async getRealEstateAssistance(userMessage, conversationHistory = []) {
    const systemPrompt = `Tu es un assistant immobilier expert en Tunisie. Tu aides les clients à:

1. **Acheter ou louer** un bien immobilier adapté à leurs besoins
2. **Comprendre le marché** immobilier tunisien
3. **Conseiller sur les démarches** d'achat/location
4. **Estimer les budgets** nécessaires
5. **Expliquer les quartiers** et zones populaires

**Contexte du marché tunisien:**
- Villes principales: Tunis, Sfax, Sousse, Bizerte, Gabès
- Prix moyens: 
  * Appartement: 150,000 TND (vente), 800 TND/mois (location)
  * Maison: 250,000 TND (vente), 1,200 TND/mois (location)
  * Villa: 500,000 TND (vente), 2,500 TND/mois (location)
  * Studio: 80,000 TND (vente), 500 TND/mois (location)

**Ton style:**
- Professionnel mais accessible
- Pose des questions de qualification (budget, zone, type de bien)
- Donne des conseils pratiques
- Reste concis (3-4 paragraphes maximum)

**Questions de qualification à poser:**
1. Quel est votre budget approximatif?
2. Dans quelle ville/zone cherchez-vous?
3. Quel type de bien vous intéresse?
4. C'est pour acheter ou louer?
5. Combien de pièces minimum?

Réponds en français de manière naturelle et utile.`;

    const messages = [
      { role: 'system', content: systemPrompt },
      ...conversationHistory,
      { role: 'user', content: userMessage }
    ];

    return await this.chat(messages);
  }

  // Questions suggérées pour guider l'utilisateur
  getSuggestedQuestions() {
    return [
      "Quel budget prévoir pour acheter un appartement à Tunis?",
      "Quels sont les meilleurs quartiers pour une famille?",
      "Comment estimer le prix de vente d'un bien?",
      "Quels documents nécessaires pour acheter?",
      "Différence entre location courte et longue durée?",
      "Comment négocier le prix d'un bien immobilier?",
      "Quels frais supplémentaires prévoir lors d'un achat?",
      "Comment vérifier la légalité d'un bien?",
      "Investissement locatif: rentable en Tunisie?",
      "Aides et crédits immobiliers disponibles?"
    ];
  }

  // Analyser les besoins du client à partir de la conversation
  async analyzeClientNeeds(conversationHistory) {
    const analysisPrompt = `Analyse la conversation suivante et extrais les informations clés du client:

Conversation: ${JSON.stringify(conversationHistory)}

Retourne un JSON avec:
{
  "budget": "montant ou 'non précisé'",
  "location": "ville/zone ou 'non précisé'",
  "propertyType": "type de bien ou 'non précisé'",
  "transactionType": "achat/location ou 'non précisé'",
  "rooms": "nombre ou 'non précisé'",
  "priorities": ["liste des priorités mentionnées"],
  "readinessLevel": "high/medium/low" (estimation de la maturité du projet)
}`;

    const messages = [
      { role: 'user', content: analysisPrompt }
    ];

    try {
      const response = await this.chat(messages, 0.3);
      return JSON.parse(response);
    } catch (error) {
      console.error('Analysis error:', error);
      return null;
    }
  }
}

// Singleton
const openaiService = new OpenAIService();

module.exports = openaiService;
