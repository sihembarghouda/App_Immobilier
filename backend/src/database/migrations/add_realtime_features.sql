-- Migration: Add presence, sessions, notifications tables and security features
-- Execute: psql -U postgres -d immobilier_db -f add_realtime_features.sql

-- Table de présence utilisateur
CREATE TABLE IF NOT EXISTS user_presence (
  user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  is_online BOOLEAN DEFAULT false,
  last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  socket_id VARCHAR(255),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_presence_online ON user_presence(is_online);
CREATE INDEX idx_user_presence_last_seen ON user_presence(last_seen);

-- Table des sessions (appareils connectés)
CREATE TABLE IF NOT EXISTS sessions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) UNIQUE,
  device_name VARCHAR(255),
  device_type VARCHAR(50), -- 'mobile', 'web', 'tablet'
  ip_address VARCHAR(45),
  user_agent TEXT,
  last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_token_hash ON sessions(token_hash);
CREATE INDEX idx_sessions_expires_at ON sessions(expires_at);

-- Table des notifications
CREATE TABLE IF NOT EXISTS notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL, -- 'message', 'favorite', 'property', 'system'
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX idx_notifications_type ON notifications(type);

-- Ajouter colonnes 2FA aux utilisateurs (si elles n'existent pas déjà)
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='users' AND column_name='two_factor_secret') THEN
    ALTER TABLE users ADD COLUMN two_factor_secret VARCHAR(255);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='users' AND column_name='two_factor_enabled') THEN
    ALTER TABLE users ADD COLUMN two_factor_enabled BOOLEAN DEFAULT false;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='users' AND column_name='two_factor_backup_codes') THEN
    ALTER TABLE users ADD COLUMN two_factor_backup_codes JSONB DEFAULT '[]';
  END IF;
END $$;

-- Fonction pour nettoyer les sessions expirées
CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS void AS $$
BEGIN
  DELETE FROM sessions WHERE expires_at < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour marquer utilisateur hors ligne après inactivité
CREATE OR REPLACE FUNCTION mark_inactive_users_offline()
RETURNS void AS $$
BEGIN
  UPDATE user_presence
  SET is_online = false
  WHERE is_online = true
    AND last_seen < CURRENT_TIMESTAMP - INTERVAL '5 minutes';
END;
$$ LANGUAGE plpgsql;

-- Créer des index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_properties_created_at ON properties(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_favorites_created_at ON favorites(created_at DESC);

-- Statistiques
SELECT 'Migration completed successfully!' AS status;
SELECT 
  'user_presence' AS table_name,
  COUNT(*) AS row_count 
FROM user_presence
UNION ALL
SELECT 
  'sessions' AS table_name,
  COUNT(*) AS row_count 
FROM sessions
UNION ALL
SELECT 
  'notifications' AS table_name,
  COUNT(*) AS row_count 
FROM notifications;
