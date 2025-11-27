// src/controllers/ai.controller.js
const pool = require('../config/database');
const openaiService = require('../services/openai.service');

// Chat avec l'assistant AI
exports.chat = async (req, res) => {
  try {
    const { message, conversationHistory = [] } = req.body;
    const userId = req.user?.id;

    if (!message) {
      return res.status(400).json({
        success: false,
        message: 'Message requis'
      });
    }

    // Obtenir la réponse de l'AI
    const response = await openaiService.getRealEstateAssistance(
      message,
      conversationHistory
    );

    // Sauvegarder la conversation si utilisateur connecté
    if (userId) {
      const client = await pool.connect();
      try {
        // Créer la table si elle n'existe pas
        await client.query(`
          CREATE TABLE IF NOT EXISTS ai_conversations (
            id SERIAL PRIMARY KEY,
            user_id INTEGER REFERENCES users(id),
            user_message TEXT,
            ai_response TEXT,
            context JSONB,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        `);
        
        await client.query(
          `INSERT INTO ai_conversations (user_id, user_message, ai_response, context)
           VALUES ($1, $2, $3, $4)`,
          [userId, message, response, JSON.stringify(conversationHistory)]
        );
      } catch (dbError) {
        console.error('DB save error:', dbError);
      } finally {
        client.release();
      }
    }

    res.json({
      success: true,
      data: {
        response: response,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('AI chat error:', error);
    
    const fallbackResponse = `Je suis désolé, je rencontre actuellement des difficultés techniques. 

En attendant, voici quelques informations générales:
- Pour acheter un bien en Tunisie, prévoyez environ 150,000 TND pour un appartement
- Les quartiers populaires à Tunis: La Marsa, Les Berges du Lac, Ennasr
- Documents nécessaires: CIN, justificatif de revenus, compromis de vente

N'hésitez pas à consulter nos annonces ou à me reposer votre question dans quelques instants.`;

    res.json({
      success: true,
      data: {
        response: fallbackResponse,
        timestamp: new Date().toISOString(),
        fallback: true
      }
    });
  }
};

// Obtenir les questions suggérées
exports.getSuggestedQuestions = async (req, res) => {
  try {
    const questions = openaiService.getSuggestedQuestions();

    res.json({
      success: true,
      data: {
        questions: questions
      }
    });
  } catch (error) {
    console.error('Get questions error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des questions'
    });
  }
};

// Analyser les besoins du client
exports.analyzeNeeds = async (req, res) => {
  try {
    const { conversationHistory } = req.body;

    if (!conversationHistory || conversationHistory.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Historique de conversation requis'
      });
    }

    const analysis = await openaiService.analyzeClientNeeds(conversationHistory);

    res.json({
      success: true,
      data: {
        analysis: analysis
      }
    });
  } catch (error) {
    console.error('Analyze needs error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'analyse'
    });
  }
};

// Obtenir l'historique des conversations
exports.getConversationHistory = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;
    const { limit = 20 } = req.query;

    const result = await client.query(
      `SELECT id, user_message, ai_response, created_at
       FROM ai_conversations
       WHERE user_id = $1
       ORDER BY created_at DESC
       LIMIT $2`,
      [userId, limit]
    );

    res.json({
      success: true,
      data: {
        conversations: result.rows
      }
    });
  } catch (error) {
    console.error('Get history error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération'
    });
  } finally {
    client.release();
  }
};

// AI Matching: Recommander des propriétés pour un acheteur
exports.getRecommendations = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;
    const { maxPrice, city, type, minRooms } = req.query;

    // Récupérer les favoris de l'utilisateur pour comprendre ses préférences
    const favoritesResult = await client.query(`
      SELECT p.type, p.city, p.price, p.rooms
      FROM favorites f
      JOIN properties p ON f.property_id = p.id
      WHERE f.user_id = $1
      ORDER BY f.created_at DESC
      LIMIT 10
    `, [userId]);

    const favorites = favoritesResult.rows;

    // Calculer les préférences moyennes basées sur les favoris
    let avgPrice = maxPrice;
    let preferredCities = city ? [city] : [];
    let preferredTypes = type ? [type] : [];

    if (favorites.length > 0) {
      // Prix moyen des favoris
      const totalPrice = favorites.reduce((sum, f) => sum + parseFloat(f.price), 0);
      avgPrice = avgPrice || totalPrice / favorites.length;

      // Villes préférées (par fréquence)
      const cityCounts = {};
      favorites.forEach(f => {
        cityCounts[f.city] = (cityCounts[f.city] || 0) + 1;
      });
      preferredCities = Object.keys(cityCounts).sort((a, b) => cityCounts[b] - cityCounts[a]);

      // Types préférés
      const typeCounts = {};
      favorites.forEach(f => {
        typeCounts[f.type] = (typeCounts[f.type] || 0) + 1;
      });
      preferredTypes = Object.keys(typeCounts).sort((a, b) => typeCounts[b] - typeCounts[a]);
    }

    // Construire la requête de recommandation
    let query = `
      SELECT 
        p.*,
        u.name as owner_name,
        u.phone as owner_phone,
        CASE
          WHEN f.id IS NOT NULL THEN true
          ELSE false
        END as is_favorite,
        -- Score de matching (0-100)
        (
          -- Prix similaire (40 points)
          CASE 
            WHEN $2 IS NOT NULL AND p.price <= $2 THEN 40
            WHEN $2 IS NULL THEN 20
            ELSE GREATEST(0, 40 - (ABS(p.price - $2) / $2 * 40))
          END +
          -- Ville préférée (30 points)
          CASE 
            WHEN $3::text[] IS NOT NULL AND p.city = ANY($3::text[]) THEN 30
            ELSE 0
          END +
          -- Type préféré (20 points)
          CASE 
            WHEN $4::text[] IS NOT NULL AND p.type = ANY($4::text[]) THEN 20
            ELSE 0
          END +
          -- Nombre de pièces (10 points)
          CASE 
            WHEN $5 IS NOT NULL AND p.rooms >= $5 THEN 10
            ELSE 5
          END
        ) as match_score
      FROM properties p
      LEFT JOIN users u ON p.owner_id = u.id
      LEFT JOIN favorites f ON f.property_id = p.id AND f.user_id = $1
      WHERE p.owner_id != $1
      ORDER BY match_score DESC, p.created_at DESC
      LIMIT 20
    `;

    const recommendations = await client.query(query, [
      userId,
      avgPrice || null,
      preferredCities.length > 0 ? preferredCities : null,
      preferredTypes.length > 0 ? preferredTypes : null,
      minRooms || null
    ]);

    res.json({
      success: true,
      data: {
        recommendations: recommendations.rows,
        preferences: {
          avgPrice: avgPrice ? Math.round(avgPrice) : null,
          cities: preferredCities,
          types: preferredTypes,
          basedOnFavorites: favorites.length
        }
      }
    });
  } catch (error) {
    console.error('Get recommendations error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des recommandations'
    });
  } finally {
    client.release();
  }
};

// AI Matching: Trouver des acheteurs potentiels pour une propriété (vendeur)
exports.getPotentialBuyers = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { propertyId } = req.params;
    const userId = req.user.id;

    // Vérifier que la propriété appartient à l'utilisateur
    const propertyCheck = await client.query(
      'SELECT * FROM properties WHERE id = $1 AND owner_id = $2',
      [propertyId, userId]
    );

    if (propertyCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Propriété non trouvée ou non autorisée'
      });
    }

    const property = propertyCheck.rows[0];

    // Trouver les acheteurs qui ont des favoris similaires
    const potentialBuyers = await client.query(`
      SELECT DISTINCT
        u.id,
        u.name,
        u.email,
        u.phone,
        COUNT(f.id) as total_favorites,
        -- Score de matching
        (
          -- A des favoris dans la même ville (40 points)
          CASE 
            WHEN EXISTS (
              SELECT 1 FROM favorites f2 
              JOIN properties p2 ON f2.property_id = p2.id 
              WHERE f2.user_id = u.id AND p2.city = $2
            ) THEN 40
            ELSE 0
          END +
          -- A des favoris du même type (30 points)
          CASE 
            WHEN EXISTS (
              SELECT 1 FROM favorites f2 
              JOIN properties p2 ON f2.property_id = p2.id 
              WHERE f2.user_id = u.id AND p2.type = $3
            ) THEN 30
            ELSE 0
          END +
          -- Prix dans la fourchette (30 points)
          CASE 
            WHEN EXISTS (
              SELECT 1 FROM favorites f2 
              JOIN properties p2 ON f2.property_id = p2.id 
              WHERE f2.user_id = u.id 
                AND p2.price BETWEEN $4 * 0.8 AND $4 * 1.2
            ) THEN 30
            ELSE 0
          END
        ) as match_score
      FROM users u
      LEFT JOIN favorites f ON f.user_id = u.id
      WHERE u.role = ANY($5::text[])
        AND u.id != $1
      GROUP BY u.id, u.name, u.email, u.phone
      HAVING COUNT(f.id) > 0
      ORDER BY match_score DESC, total_favorites DESC
      LIMIT 10
    `, [userId, property.city, property.type, property.price, ['buyer','acheteur']]);

    res.json({
      success: true,
      data: {
        property: {
          id: property.id,
          title: property.title,
          city: property.city,
          type: property.type,
          price: property.price
        },
        potentialBuyers: potentialBuyers.rows
      }
    });
  } catch (error) {
    console.error('Get potential buyers error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des acheteurs potentiels'
    });
  } finally {
    client.release();
  }
};

// AI Matching: Suggestions intelligentes basées sur l'historique
exports.getSmartSuggestions = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;

    // Analyser l'activité récente de l'utilisateur
    const [recentViews, recentFavorites, recentMessages] = await Promise.all([
      // Simuler les vues récentes (à implémenter avec une table views)
      client.query('SELECT 1 LIMIT 0'),
      
      // Favoris récents
      client.query(`
        SELECT p.* FROM favorites f
        JOIN properties p ON f.property_id = p.id
        WHERE f.user_id = $1
        ORDER BY f.created_at DESC
        LIMIT 5
      `, [userId]),
      
      // Conversations récentes
      client.query(`
        SELECT DISTINCT p.* FROM messages m
        JOIN properties p ON p.owner_id = m.receiver_id OR p.owner_id = m.sender_id
        WHERE (m.sender_id = $1 OR m.receiver_id = $1)
          AND p.owner_id != $1
        ORDER BY m.created_at DESC
        LIMIT 5
      `, [userId])
    ]);

    // Combiner et analyser les patterns
    const allProperties = [
      ...recentFavorites.rows,
      ...recentMessages.rows
    ];

    // Extraire les patterns
    const cities = {};
    const types = {};
    const priceRanges = { min: Infinity, max: 0 };

    allProperties.forEach(p => {
      cities[p.city] = (cities[p.city] || 0) + 1;
      types[p.type] = (types[p.type] || 0) + 1;
      priceRanges.min = Math.min(priceRanges.min, parseFloat(p.price));
      priceRanges.max = Math.max(priceRanges.max, parseFloat(p.price));
    });

    const topCity = Object.keys(cities).sort((a, b) => cities[b] - cities[a])[0];
    const topType = Object.keys(types).sort((a, b) => types[b] - types[a])[0];

    // Suggestions basées sur les patterns
    const suggestions = await client.query(`
      SELECT 
        p.*,
        u.name as owner_name,
        u.phone as owner_phone
      FROM properties p
      LEFT JOIN users u ON p.owner_id = u.id
      LEFT JOIN favorites f ON f.property_id = p.id AND f.user_id = $1
      WHERE p.owner_id != $1
        AND f.id IS NULL
        AND (
          p.city = $2
          OR p.type = $3
          OR (p.price BETWEEN $4 AND $5)
        )
      ORDER BY 
        CASE WHEN p.city = $2 AND p.type = $3 THEN 1 ELSE 2 END,
        p.created_at DESC
      LIMIT 15
    `, [
      userId,
      topCity || '',
      topType || 'apartment',
      priceRanges.min !== Infinity ? priceRanges.min : 0,
      priceRanges.max > 0 ? priceRanges.max : 999999999
    ]);

    res.json({
      success: true,
      data: {
        suggestions: suggestions.rows,
        insights: {
          preferredCity: topCity,
          preferredType: topType,
          priceRange: priceRanges.min !== Infinity ? {
            min: Math.round(priceRanges.min),
            max: Math.round(priceRanges.max)
          } : null,
          basedOn: {
            favorites: recentFavorites.rows.length,
            conversations: recentMessages.rows.length
          }
        }
      }
    });
  } catch (error) {
    console.error('Get smart suggestions error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des suggestions'
    });
  } finally {
    client.release();
  }
};
