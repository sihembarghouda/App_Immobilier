// Script pour générer des propriétés dans différentes villes de Tunisie
require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'immobilier_db'
});

// Villes tunisiennes avec coordonnées
const cities = [
  { name: 'Tunis', lat: 36.8065, lng: 10.1815, zones: ['Centre-Ville', 'Bab Bhar', 'Medina', 'Lafayette', 'Passage'] },
  { name: 'Ariana', lat: 36.8625, lng: 10.1956, zones: ['Soukra', 'Ennasr', 'Ghazela', 'Mnihla', 'Raoued'] },
  { name: 'La Marsa', lat: 36.8781, lng: 10.3247, zones: ['Marsa Plage', 'Sidi Daoued', 'Marsa Cube', 'Gammarth'] },
  { name: 'Carthage', lat: 36.8531, lng: 10.3239, zones: ['Carthage Présidence', 'Byrsa', 'Hannibal', 'Salammbô'] },
  { name: 'Menzah', lat: 36.8380, lng: 10.1686, zones: ['Menzah 5', 'Menzah 6', 'Menzah 7', 'Menzah 8', 'Menzah 9'] },
  { name: 'Manar', lat: 36.8456, lng: 10.1936, zones: ['Manar 1', 'Manar 2', 'Campus'] },
  { name: 'Ben Arous', lat: 36.7474, lng: 10.2189, zones: ['Centre', 'Ezzahra', 'Radès', 'Fouchana'] },
  { name: 'Sfax', lat: 34.7400, lng: 10.7600, zones: ['Centre-Ville', 'Sfax El Jadida', 'Route Gremda', 'Sakiet Ezzit'] },
  { name: 'Sousse', lat: 35.8256, lng: 10.6369, zones: ['Centre-Ville', 'Khezama', 'Sahloul', 'Sousse Jaouhara'] },
  { name: 'Hammamet', lat: 36.3997, lng: 10.6131, zones: ['Hammamet Nord', 'Hammamet Sud', 'Yasmine', 'Nabeul'] },
  { name: 'Monastir', lat: 35.7774, lng: 10.8264, zones: ['Centre', 'Route Sahline', 'Skanes', 'Khniss'] },
  { name: 'Bizerte', lat: 37.2744, lng: 9.8739, zones: ['Centre', 'Corniche', 'Menzel Bourguiba', 'Zarzouna'] },
  { name: 'Kairouan', lat: 35.6781, lng: 10.0967, zones: ['Medina', 'Centre', 'Route Sousse'] },
  { name: 'Nabeul', lat: 36.4561, lng: 10.7372, zones: ['Centre', 'Dar Châabane', 'Beni Khiar', 'Menzel Temime'] }
];

const propertyTypes = ['apartment', 'house', 'villa', 'studio'];
const transactionTypes = ['sale', 'rent'];

const titles = {
  apartment: {
    sale: [
      'Appartement moderne à vendre',
      'Bel appartement F3',
      'Appartement spacieux avec balcon',
      'Appartement neuf standing',
      'F4 lumineux avec parking'
    ],
    rent: [
      'Appartement à louer meublé',
      'F2 disponible immédiatement',
      'Location appartement avec terrasse',
      'Studio moderne à louer',
      'Appartement résidentiel à louer'
    ]
  },
  house: {
    sale: [
      'Maison individuelle à vendre',
      'Belle maison avec jardin',
      'Maison familiale spacieuse',
      'Villa S+3 avec piscine',
      'Maison récente plain-pied'
    ],
    rent: [
      'Maison à louer quartier calme',
      'Location maison meublée',
      'Maison avec jardin disponible',
      'Villa à louer résidence sécurisée',
      'Location saisonnière villa'
    ]
  },
  villa: {
    sale: [
      'Villa de luxe à vendre',
      'Magnifique villa avec piscine',
      'Villa moderne haut standing',
      'Villa architecte avec jardin',
      'Superbe villa vue mer'
    ],
    rent: [
      'Villa de prestige à louer',
      'Location villa meublée',
      'Villa avec piscine disponible',
      'Location longue durée villa',
      'Villa standing à louer'
    ]
  },
  studio: {
    sale: [
      'Studio à vendre bien situé',
      'Studio neuf investissement',
      'Joli studio avec coin cuisine',
      'Studio récent à vendre',
      'Studio idéal premier achat'
    ],
    rent: [
      'Studio meublé à louer',
      'Location studio étudiant',
      'Studio disponible centre-ville',
      'Studio moderne à louer',
      'Location studio confort'
    ]
  }
};

const descriptions = [
  'Superbe propriété dans un quartier recherché, proche de toutes commodités.',
  'Bien immobilier de qualité avec finitions soignées et emplacement privilégié.',
  'Propriété récente offrant confort et modernité dans un cadre agréable.',
  'Excellent emplacement avec accès facile aux transports, écoles et commerces.',
  'Bien entretenu dans une résidence calme et sécurisée.',
  'Opportunité rare dans un secteur en pleine expansion.',
  'Cadre de vie exceptionnel avec toutes les commodités à proximité.',
  'Propriété lumineuse et spacieuse, idéale pour famille.'
];

function getRandomElement(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function getRandomPrice(type, transactionType) {
  if (transactionType === 'rent') {
    switch (type) {
      case 'studio': return getRandomInt(250, 500);
      case 'apartment': return getRandomInt(400, 1200);
      case 'house': return getRandomInt(800, 2000);
      case 'villa': return getRandomInt(1500, 5000);
    }
  } else {
    switch (type) {
      case 'studio': return getRandomInt(40000, 80000);
      case 'apartment': return getRandomInt(80000, 250000);
      case 'house': return getRandomInt(150000, 500000);
      case 'villa': return getRandomInt(300000, 1500000);
    }
  }
}

function getPropertyDetails(type) {
  switch (type) {
    case 'studio':
      return {
        surface: getRandomInt(25, 45),
        rooms: 1,
        bedrooms: 0,
        bathrooms: 1
      };
    case 'apartment':
      return {
        surface: getRandomInt(60, 150),
        rooms: getRandomInt(2, 5),
        bedrooms: getRandomInt(1, 3),
        bathrooms: getRandomInt(1, 2)
      };
    case 'house':
      return {
        surface: getRandomInt(120, 300),
        rooms: getRandomInt(4, 8),
        bedrooms: getRandomInt(2, 5),
        bathrooms: getRandomInt(2, 4)
      };
    case 'villa':
      return {
        surface: getRandomInt(200, 600),
        rooms: getRandomInt(6, 12),
        bedrooms: getRandomInt(3, 7),
        bathrooms: getRandomInt(3, 6)
      };
  }
}

async function generateProperties(count = 500) {
  const client = await pool.connect();
  
  try {
    // Get a user to be the owner (first user in database)
    const ownerResult = await client.query('SELECT id FROM users LIMIT 1');
    if (ownerResult.rows.length === 0) {
      console.log('❌ No users found. Please create a user first.');
      return;
    }
    const ownerId = ownerResult.rows[0].id;

    console.log(`🏠 Generating ${count} properties across Tunisia...`);

    for (let i = 0; i < count; i++) {
      const city = getRandomElement(cities);
      const zone = getRandomElement(city.zones);
      const type = getRandomElement(propertyTypes);
      const transactionType = getRandomElement(transactionTypes);
      
      // Random offset for coordinates within city
      const lat = city.lat + (Math.random() - 0.5) * 0.1;
      const lng = city.lng + (Math.random() - 0.5) * 0.1;
      
      const details = getPropertyDetails(type);
      const price = getRandomPrice(type, transactionType);
      const title = getRandomElement(titles[type][transactionType]) + ` - ${zone}`;
      const description = getRandomElement(descriptions);
      const address = `${zone}, ${city.name}`;
      
      // Random images (placeholder URLs - replace with actual images)
      const images = [
        `https://picsum.photos/800/600?random=${i + 1}`,
        `https://picsum.photos/800/600?random=${i + 1001}`,
        `https://picsum.photos/800/600?random=${i + 2001}`
      ];

      await client.query(
        `INSERT INTO properties 
        (title, description, type, transaction_type, price, surface, rooms, bedrooms, bathrooms, 
         address, city, latitude, longitude, images, owner_id, created_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, NOW())`,
        [
          title,
          description,
          type,
          transactionType,
          price,
          details.surface,
          details.rooms,
          details.bedrooms,
          details.bathrooms,
          address,
          city.name,
          lat,
          lng,
          JSON.stringify(images),
          ownerId
        ]
      );

      if ((i + 1) % 50 === 0) {
        console.log(`✅ ${i + 1}/${count} properties generated`);
      }
    }

    console.log('🎉 All properties generated successfully!');
    console.log('\n📊 Distribution:');
    
    const stats = await client.query(`
      SELECT city, type, transaction_type, COUNT(*) as count
      FROM properties
      GROUP BY city, type, transaction_type
      ORDER BY city, type, transaction_type
    `);
    
    console.table(stats.rows);

  } catch (error) {
    console.error('❌ Error generating properties:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

// Run the script
const count = process.argv[2] ? parseInt(process.argv[2]) : 500;
generateProperties(count);
