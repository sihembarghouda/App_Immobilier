// Seed diverse properties across multiple Tunisian cities
const pool = require('../config/database');

const tunisianCities = [
  { name: 'Tunis', lat: 36.8065, lng: 10.1815 },
  { name: 'Sfax', lat: 34.7406, lng: 10.7603 },
  { name: 'Sousse', lat: 35.8256, lng: 10.6369 },
  { name: 'Kairouan', lat: 35.6781, lng: 10.0963 },
  { name: 'Bizerte', lat: 37.2746, lng: 9.8739 },
  { name: 'Gabès', lat: 33.8815, lng: 10.0982 },
  { name: 'Ariana', lat: 36.8625, lng: 10.1956 },
  { name: 'Nabeul', lat: 36.4561, lng: 10.7356 },
  { name: 'La Marsa', lat: 36.8781, lng: 10.3247 },
  { name: 'Hammamet', lat: 36.3997, lng: 10.6167 },
  { name: 'Monastir', lat: 35.7770, lng: 10.8261 },
  { name: 'Ben Arous', lat: 36.7540, lng: 10.2189 }
];

const propertyTypes = ['apartment', 'house', 'villa', 'studio'];
const transactionTypes = ['sale', 'rent'];

const apartmentDescriptions = [
  'Appartement moderne au cœur de {city}',
  'Bel appartement lumineux avec balcon',
  'Appartement rénové proche commodités',
  'Grand appartement familial {rooms} pièces',
  'Appartement standing avec vue panoramique'
];

const houseDescriptions = [
  'Maison confortable dans quartier calme',
  'Belle maison avec jardin',
  'Maison traditionnelle tunisienne rénovée',
  'Maison spacieuse idéale pour famille',
  'Charmante maison proche centre-ville'
];

const villaDescriptions = [
  'Villa de luxe avec piscine',
  'Magnifique villa moderne',
  'Villa d\'exception vue mer',
  'Villa spacieuse avec grand jardin',
  'Villa contemporaine haut standing'
];

const studioDescriptions = [
  'Studio moderne bien équipé',
  'Petit studio cosy centre-ville',
  'Studio meublé proche université',
  'Studio lumineux avec kitchenette',
  'Studio indépendant avec parking'
];

function getRandomElement(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function generateDescription(type, city, rooms) {
  let templates;
  switch(type) {
    case 'apartment':
      templates = apartmentDescriptions;
      break;
    case 'house':
      templates = houseDescriptions;
      break;
    case 'villa':
      templates = villaDescriptions;
      break;
    case 'studio':
      templates = studioDescriptions;
      break;
    default:
      templates = apartmentDescriptions;
  }
  
  const template = getRandomElement(templates);
  return template.replace('{city}', city).replace('{rooms}', rooms);
}

function generatePrice(type, transactionType) {
  const basePrice = {
    'apartment': transactionType === 'sale' ? 150000 : 800,
    'house': transactionType === 'sale' ? 250000 : 1200,
    'villa': transactionType === 'sale' ? 500000 : 2500,
    'studio': transactionType === 'sale' ? 80000 : 500
  };
  
  const variation = 1 + (Math.random() * 0.5 - 0.25); // ±25%
  return Math.round(basePrice[type] * variation);
}

function generateSurface(type) {
  const baseSurface = {
    'apartment': 80,
    'house': 150,
    'villa': 300,
    'studio': 30
  };
  
  const variation = 1 + (Math.random() * 0.4 - 0.2); // ±20%
  return Math.round(baseSurface[type] * variation);
}

function generateRooms(type) {
  const baseRooms = {
    'apartment': { min: 2, max: 5 },
    'house': { min: 4, max: 8 },
    'villa': { min: 6, max: 12 },
    'studio': { min: 1, max: 1 }
  };
  
  const range = baseRooms[type];
  return getRandomInt(range.min, range.max);
}

function getImagePlaceholder(type, index) {
  const images = {
    'apartment': [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800'
    ],
    'house': [
      'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800',
      'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
      'https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?w=800'
    ],
    'villa': [
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
      'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800'
    ],
    'studio': [
      'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800',
      'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=800',
      'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800'
    ]
  };
  
  return getRandomElement(images[type] || images['apartment']);
}

async function seedDiverseProperties(count = 300) {
  const client = await pool.connect();
  
  try {
    console.log(`🌱 Starting to seed ${count} diverse properties...`);
    
    // Get existing users for owner assignment
    const usersResult = await client.query('SELECT id FROM users LIMIT 10');
    const userIds = usersResult.rows.map(row => row.id);
    
    if (userIds.length === 0) {
      console.warn('⚠️  No users found. Creating a default user...');
      const defaultUser = await client.query(
        `INSERT INTO users (name, email, password, role, phone) 
         VALUES ($1, $2, $3, $4, $5) RETURNING id`,
        ['Default Owner', 'owner@homefinder.com', 'hashed_password', 'seller', '+216 98 000 000']
      );
      userIds.push(defaultUser.rows[0].id);
    }
    
    let successCount = 0;
    let errorCount = 0;
    
    for (let i = 0; i < count; i++) {
      try {
        const city = getRandomElement(tunisianCities);
        const type = getRandomElement(propertyTypes);
        const transactionType = getRandomElement(transactionTypes);
        const rooms = generateRooms(type);
        const bedrooms = type === 'studio' ? 0 : Math.floor(rooms * 0.6);
        const bathrooms = type === 'studio' ? 1 : Math.max(1, Math.floor(rooms * 0.3));
        const surface = generateSurface(type);
        const price = generatePrice(type, transactionType);
        
        // Slight variation in coordinates (within 0.1 degree)
        const lat = city.lat + (Math.random() * 0.2 - 0.1);
        const lng = city.lng + (Math.random() * 0.2 - 0.1);
        
        const title = `${type.charAt(0).toUpperCase() + type.slice(1)} ${transactionType === 'sale' ? 'à vendre' : 'à louer'} - ${city.name}`;
        const description = generateDescription(type, city.name, rooms);
        
        // Generate 1-3 images
        const numImages = getRandomInt(1, 3);
        const images = [];
        for (let j = 0; j < numImages; j++) {
          images.push(getImagePlaceholder(type, j));
        }
        
        const ownerId = getRandomElement(userIds);
        
        await client.query(
          `INSERT INTO properties 
          (owner_id, title, description, type, transaction_type, price, surface, 
           rooms, bedrooms, bathrooms, address, city, latitude, longitude, images)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)`,
          [
            ownerId,
            title,
            description,
            type,
            transactionType,
            price,
            surface,
            rooms,
            bedrooms,
            bathrooms,
            `${getRandomInt(1, 200)} Rue de ${city.name}`,
            city.name,
            lat,
            lng,
            JSON.stringify(images)
          ]
        );
        
        successCount++;
        
        if ((i + 1) % 50 === 0) {
          console.log(`✅ Progress: ${i + 1}/${count} properties created`);
        }
      } catch (error) {
        errorCount++;
        console.error(`❌ Error creating property ${i + 1}:`, error.message);
      }
    }
    
    console.log(`\n✅ Seeding completed!`);
    console.log(`   Successfully created: ${successCount} properties`);
    console.log(`   Errors: ${errorCount}`);
    console.log(`   Distribution by city:`);
    
    // Show distribution
    const distribution = await client.query(
      `SELECT city, type, transaction_type, COUNT(*) as count 
       FROM properties 
       GROUP BY city, type, transaction_type 
       ORDER BY city, type, transaction_type`
    );
    
    distribution.rows.forEach(row => {
      console.log(`      ${row.city} - ${row.type} (${row.transaction_type}): ${row.count}`);
    });
    
  } catch (error) {
    console.error('❌ Fatal error during seeding:', error);
    throw error;
  } finally {
    client.release();
  }
}

// Execute if run directly
if (require.main === module) {
  const count = process.argv[2] ? parseInt(process.argv[2]) : 300;
  
  seedDiverseProperties(count)
    .then(() => {
      console.log('\n🎉 Seed script completed successfully!');
      process.exit(0);
    })
    .catch(error => {
      console.error('\n💥 Seed script failed:', error);
      process.exit(1);
    });
}

module.exports = { seedDiverseProperties };
