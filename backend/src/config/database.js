// src/config/database.js
const { Pool } = require('pg');
require('dotenv').config(); // <-- à garder tout en haut

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  database: process.env.DB_NAME || 'immobilier_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '0000',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('connect', () => {
  console.log('✅ Connected to PostgreSQL successfully');
});

pool.on('error', (err) => {
  console.error('❌ Unexpected PostgreSQL error', err);
  process.exit(-1);
});

module.exports = pool;


// src/database/schema.sql
/*
-- Create Database (run this manually in PostgreSQL)
CREATE DATABASE immobilier_db;

-- Connect to the database
\c immobilier_db;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    avatar VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Properties Table
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
);

-- Favorites Table
CREATE TABLE favorites (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    property_id INTEGER NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, property_id)
);

-- Messages Table
CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    sender_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    property_id INTEGER REFERENCES properties(id) ON DELETE SET NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for better performance
CREATE INDEX idx_properties_city ON properties(city);
CREATE INDEX idx_properties_type ON properties(type);
CREATE INDEX idx_properties_transaction_type ON properties(transaction_type);
CREATE INDEX idx_properties_price ON properties(price);
CREATE INDEX idx_properties_owner_id ON properties(owner_id);
CREATE INDEX idx_favorites_user_id ON favorites(user_id);
CREATE INDEX idx_favorites_property_id ON favorites(property_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_properties_updated_at BEFORE UPDATE ON properties
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data (optional)
INSERT INTO users (email, password, name, phone) VALUES
('john@example.com', '$2a$10$XqZ8J8qhY9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K', 'John Doe', '+216 98 123 456'),
('ahmed@example.com', '$2a$10$XqZ8J8qhY9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K', 'Ahmed Ben Ali', '+216 22 987 654'),
('fatma@example.com', '$2a$10$XqZ8J8qhY9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K', 'Fatma Trabelsi', '+216 55 444 333');

INSERT INTO properties (title, description, type, transaction_type, price, surface, rooms, bedrooms, bathrooms, address, city, latitude, longitude, images, owner_id) VALUES
('Appartement moderne avec vue mer', 'Bel appartement de 120m² avec vue imprenable sur la mer. Cuisine équipée, climatisation, parking.', 'apartment', 'sale', 250000.00, 120.00, 4, 3, 2, 'Avenue Habib Bourguiba', 'Tunis', 36.8065, 10.1815, ARRAY['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267'], 2),
('Villa luxueuse avec piscine', 'Magnifique villa de 350m² avec jardin et piscine. 5 chambres, garage double.', 'villa', 'sale', 850000.00, 350.00, 7, 5, 3, 'Les Berges du Lac', 'Tunis', 36.8358, 10.2578, ARRAY['https://images.unsplash.com/photo-1613490493576-7fde63acd811'], 3),
('Studio meublé centre ville', 'Studio de 45m² entièrement meublé, idéal pour étudiant ou jeune professionnel.', 'studio', 'rent', 800.00, 45.00, 1, 1, 1, 'Rue de Marseille', 'Tunis', 36.8019, 10.1868, ARRAY['https://images.unsplash.com/photo-1502672260066-6bc35f0c99f0'], 1);
*/