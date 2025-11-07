// src/database/migrate.js
require('dotenv').config();
const { Client } = require('pg');
const bcrypt = require('bcryptjs');

const runMigration = async () => {
  // Connect to postgres database first to create our database
  const client = new Client({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: 'postgres',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD,
  });

  try {
    await client.connect();
    console.log('✅ Connected to PostgreSQL');

    // Create database if not exists
    const dbName = process.env.DB_NAME || 'immobilier_db';
    await client.query(`DROP DATABASE IF EXISTS ${dbName}`);
    await client.query(`CREATE DATABASE ${dbName}`);
    console.log(`✅ Database '${dbName}' created`);

    await client.end();

    // Connect to new database
    const dbClient = new Client({
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      database: dbName,
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD,
    });

    await dbClient.connect();

    // Create tables
    console.log('📝 Creating tables...');

    // Enable UUID extension
    await dbClient.query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"');

    // Users table
    await dbClient.query(`
      CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        name VARCHAR(255) NOT NULL,
        phone VARCHAR(50),
        avatar VARCHAR(500),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Users table created');

    // Properties table
    await dbClient.query(`
      CREATE TABLE properties (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        type VARCHAR(50) NOT NULL CHECK (type IN ('apartment', 'house', 'villa', 'studio')),
        transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN ('sale', 'rent')),
        price DECIMAL(12, 2) NOT NULL,
        surface DECIMAL(10, 2) NOT NULL,
        rooms INTEGER NOT NULL,
        bedrooms INTEGER NOT NULL,
        bathrooms INTEGER NOT NULL,
        address VARCHAR(500) NOT NULL,
        city VARCHAR(100) NOT NULL,
        latitude DECIMAL(10, 8) NOT NULL,
        longitude DECIMAL(11, 8) NOT NULL,
        images TEXT[] DEFAULT '{}',
        owner_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Properties table created');

    // Favorites table
    await dbClient.query(`
      CREATE TABLE favorites (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        property_id INTEGER NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, property_id)
      )
    `);
    console.log('✅ Favorites table created');

    // Messages table
    await dbClient.query(`
      CREATE TABLE messages (
        id SERIAL PRIMARY KEY,
        sender_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        receiver_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        content TEXT NOT NULL,
        property_id INTEGER REFERENCES properties(id) ON DELETE SET NULL,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Messages table created');

    // Create indexes
    console.log('📝 Creating indexes...');
    await dbClient.query('CREATE INDEX idx_properties_city ON properties(city)');
    await dbClient.query('CREATE INDEX idx_properties_type ON properties(type)');
    await dbClient.query('CREATE INDEX idx_properties_transaction_type ON properties(transaction_type)');
    await dbClient.query('CREATE INDEX idx_properties_price ON properties(price)');
    await dbClient.query('CREATE INDEX idx_properties_owner_id ON properties(owner_id)');
    await dbClient.query('CREATE INDEX idx_favorites_user_id ON favorites(user_id)');
    await dbClient.query('CREATE INDEX idx_favorites_property_id ON favorites(property_id)');
    await dbClient.query('CREATE INDEX idx_messages_sender_id ON messages(sender_id)');
    await dbClient.query('CREATE INDEX idx_messages_receiver_id ON messages(receiver_id)');
    await dbClient.query('CREATE INDEX idx_messages_created_at ON messages(created_at DESC)');
    console.log('✅ Indexes created');

    // Create triggers
    console.log('📝 Creating triggers...');
    await dbClient.query(`
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = CURRENT_TIMESTAMP;
        RETURN NEW;
      END;
      $$ language 'plpgsql'
    `);

    await dbClient.query(`
      CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()
    `);

    await dbClient.query(`
      CREATE TRIGGER update_properties_updated_at BEFORE UPDATE ON properties
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()
    `);

    await dbClient.query(`
      CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()
    `);
    console.log('✅ Triggers created');

    // Insert sample data
    console.log('📝 Inserting sample data...');

    // Hash passwords
    const hashedPassword = await bcrypt.hash('password123', 10);

    // Insert users
    const usersResult = await dbClient.query(
      `INSERT INTO users (email, password, name, phone) VALUES
        ('john@example.com', $1, 'John Doe', '+216 98 123 456'),
        ('ahmed@example.com', $1, 'Ahmed Ben Ali', '+216 22 987 654'),
        ('fatma@example.com', $1, 'Fatma Trabelsi', '+216 55 444 333')
      RETURNING id`,
      [hashedPassword]
    );
    console.log('✅ Sample users created');

    // Insert properties
    await dbClient.query(
      `INSERT INTO properties (title, description, type, transaction_type, price, surface, rooms, bedrooms, bathrooms, address, city, latitude, longitude, images, owner_id) VALUES
        ('Appartement moderne avec vue mer', 'Bel appartement de 120m² avec vue imprenable sur la mer. Cuisine équipée, climatisation, parking.', 'apartment', 'sale', 250000.00, 120.00, 4, 3, 2, 'Avenue Habib Bourguiba', 'Tunis', 36.8065, 10.1815, ARRAY['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267'], $1),
        ('Villa luxueuse avec piscine', 'Magnifique villa de 350m² avec jardin et piscine. 5 chambres, garage double.', 'villa', 'sale', 850000.00, 350.00, 7, 5, 3, 'Les Berges du Lac', 'Tunis', 36.8358, 10.2578, ARRAY['https://images.unsplash.com/photo-1613490493576-7fde63acd811'], $2),
        ('Studio meublé centre ville', 'Studio de 45m² entièrement meublé, idéal pour étudiant ou jeune professionnel.', 'studio', 'rent', 800.00, 45.00, 1, 1, 1, 'Rue de Marseille', 'Tunis', 36.8019, 10.1868, ARRAY['https://images.unsplash.com/photo-1502672260066-6bc35f0c99f0'], $3),
        ('Maison spacieuse à Sousse', 'Belle maison de 200m² dans un quartier calme. 4 chambres, jardin, terrasse.', 'house', 'sale', 350000.00, 200.00, 5, 4, 2, 'Rue de la République', 'Sousse', 35.8256, 10.6369, ARRAY['https://images.unsplash.com/photo-1568605114967-8130f3a36994'], $1),
        ('Appartement en location Sfax', 'Appartement de 90m² bien situé, proche des commodités. 3 chambres.', 'apartment', 'rent', 1200.00, 90.00, 3, 2, 1, 'Avenue Habib Thameur', 'Sfax', 34.7406, 10.7603, ARRAY['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2'], $2)`,
      [usersResult.rows[1].id, usersResult.rows[0].id, usersResult.rows[2].id]
    );
    console.log('✅ Sample properties created');

    // Insert sample messages
    await dbClient.query(
      `INSERT INTO messages (sender_id, receiver_id, content) VALUES
        ($1, $2, 'Bonjour, est-ce que l''appartement est toujours disponible ?'),
        ($2, $1, 'Oui, il est disponible. Voulez-vous organiser une visite ?'),
        ($1, $2, 'Oui, je suis intéressé. Quand puis-je venir le voir ?'),
        ($3, $2, 'Bonjour, je suis intéressé par votre villa. Quel est le prix ?')`,
      [usersResult.rows[0].id, usersResult.rows[1].id, usersResult.rows[2].id]
    );
    console.log('✅ Sample messages created');

    console.log('\n🎉 Migration completed successfully!');
    console.log('\n📝 Sample credentials:');
    console.log('   Email: john@example.com');
    console.log('   Email: ahmed@example.com');
    console.log('   Email: fatma@example.com');
    console.log('   Password: password123');

    await dbClient.end();
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
};

runMigration();