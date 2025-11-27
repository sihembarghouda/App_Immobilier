// controllers/security.controller.js
const bcrypt = require('bcryptjs');
const speakeasy = require('speakeasy');
const QRCode = require('qrcode');
const pool = require('../config/database');

// Changer le mot de passe
exports.changePassword = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;
    const { currentPassword, newPassword } = req.body;

    // Validation
    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Mot de passe actuel et nouveau requis'
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Le nouveau mot de passe doit contenir au moins 6 caractères'
      });
    }

    // Récupérer l'utilisateur
    const userResult = await client.query(
      'SELECT password FROM users WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Utilisateur non trouvé'
      });
    }

    const user = userResult.rows[0];

    // Vérifier le mot de passe actuel
    const isPasswordValid = await bcrypt.compare(currentPassword, user.password);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Mot de passe actuel incorrect'
      });
    }

    // Hasher le nouveau mot de passe
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Mettre à jour
    await client.query(
      'UPDATE users SET password = $1 WHERE id = $2',
      [hashedPassword, userId]
    );

    res.json({
      success: true,
      message: 'Mot de passe modifié avec succès'
    });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors du changement de mot de passe'
    });
  } finally {
    client.release();
  }
};

// Générer secret 2FA
exports.generateTwoFactorSecret = async (req, res) => {
  try {
    const userId = req.user.id;
    const userEmail = req.user.email;

    // Générer le secret
    const secret = speakeasy.generateSecret({
      name: `HomeFinder (${userEmail})`,
      length: 32
    });

    // Générer QR code
    const qrCodeUrl = await QRCode.toDataURL(secret.otpauth_url);

    // Sauvegarder temporairement (pas encore activé)
    const client = await pool.connect();
    await client.query(
      'UPDATE users SET two_factor_secret = $1 WHERE id = $2',
      [secret.base32, userId]
    );
    client.release();

    res.json({
      success: true,
      data: {
        secret: secret.base32,
        qrCode: qrCodeUrl,
        manualEntry: secret.base32
      }
    });
  } catch (error) {
    console.error('Generate 2FA secret error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la génération du code 2FA'
    });
  }
};

// Activer 2FA
exports.enableTwoFactor = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'Code de vérification requis'
      });
    }

    // Récupérer le secret
    const userResult = await client.query(
      'SELECT two_factor_secret FROM users WHERE id = $1',
      [userId]
    );

    const secret = userResult.rows[0]?.two_factor_secret;

    if (!secret) {
      return res.status(400).json({
        success: false,
        message: 'Secret 2FA non généré'
      });
    }

    // Vérifier le token
    const verified = speakeasy.totp.verify({
      secret: secret,
      encoding: 'base32',
      token: token,
      window: 2
    });

    if (!verified) {
      return res.status(400).json({
        success: false,
        message: 'Code de vérification invalide'
      });
    }

    // Générer codes de secours
    const backupCodes = [];
    for (let i = 0; i < 10; i++) {
      const code = Math.random().toString(36).substring(2, 10).toUpperCase();
      backupCodes.push(await bcrypt.hash(code, 10));
    }

    // Activer 2FA
    await client.query(
      `UPDATE users 
       SET two_factor_enabled = true,
           two_factor_backup_codes = $1
       WHERE id = $2`,
      [JSON.stringify(backupCodes), userId]
    );

    res.json({
      success: true,
      message: 'Authentification à deux facteurs activée',
      data: {
        backupCodes: backupCodes.map((_, i) => 
          Math.random().toString(36).substring(2, 10).toUpperCase()
        )
      }
    });
  } catch (error) {
    console.error('Enable 2FA error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'activation de la 2FA'
    });
  } finally {
    client.release();
  }
};

// Désactiver 2FA
exports.disableTwoFactor = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Mot de passe requis pour désactiver la 2FA'
      });
    }

    // Vérifier le mot de passe
    const userResult = await client.query(
      'SELECT password FROM users WHERE id = $1',
      [userId]
    );

    const isPasswordValid = await bcrypt.compare(
      password,
      userResult.rows[0].password
    );

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Mot de passe incorrect'
      });
    }

    // Désactiver 2FA
    await client.query(
      `UPDATE users 
       SET two_factor_enabled = false,
           two_factor_secret = NULL,
           two_factor_backup_codes = '[]'
       WHERE id = $1`,
      [userId]
    );

    res.json({
      success: true,
      message: 'Authentification à deux facteurs désactivée'
    });
  } catch (error) {
    console.error('Disable 2FA error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la désactivation de la 2FA'
    });
  } finally {
    client.release();
  }
};

// Lister les sessions actives
exports.getActiveSessions = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;

    const result = await client.query(
      `SELECT 
        id,
        device_name,
        device_type,
        ip_address,
        last_activity,
        created_at
       FROM sessions
       WHERE user_id = $1 AND expires_at > CURRENT_TIMESTAMP
       ORDER BY last_activity DESC`,
      [userId]
    );

    res.json({
      success: true,
      data: result.rows
    });
  } catch (error) {
    console.error('Get sessions error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des sessions'
    });
  } finally {
    client.release();
  }
};

// Révoquer une session
exports.revokeSession = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;
    const { sessionId } = req.params;

    await client.query(
      'DELETE FROM sessions WHERE id = $1 AND user_id = $2',
      [sessionId, userId]
    );

    res.json({
      success: true,
      message: 'Session révoquée'
    });
  } catch (error) {
    console.error('Revoke session error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la révocation de la session'
    });
  } finally {
    client.release();
  }
};

// Révoquer toutes les sessions sauf la courante
exports.revokeAllSessions = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;
    const currentTokenHash = req.tokenHash; // À définir dans le middleware

    await client.query(
      'DELETE FROM sessions WHERE user_id = $1 AND token_hash != $2',
      [userId, currentTokenHash]
    );

    res.json({
      success: true,
      message: 'Toutes les autres sessions ont été révoquées'
    });
  } catch (error) {
    console.error('Revoke all sessions error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la révocation des sessions'
    });
  } finally {
    client.release();
  }
};

module.exports = exports;
