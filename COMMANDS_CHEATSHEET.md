# ⚡ COMMANDES RAPIDES - ImmoTunisie

## 🎨 1. LOGO ET ICÔNES

```bash
# Après avoir créé app_logo.png dans assets/images/
cd frontend
flutter pub add dev:flutter_launcher_icons
flutter pub run flutter_launcher_icons
```

## 🔐 2. CRÉER KEYSTORE

```bash
cd frontend/android
keytool -genkey -v -keystore immotunisie-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
# NOTER LE MOT DE PASSE !
```

## 📝 3. CONFIGURER SIGNATURE

Créer `frontend/android/key.properties` :
```properties
storePassword=VOTRE_MOT_DE_PASSE
keyPassword=VOTRE_MOT_DE_PASSE
keyAlias=upload
storeFile=immotunisie-upload-key.jks
```

## 🏗️ 4. BUILD AAB

```bash
cd frontend
flutter clean
flutter pub get
flutter build appbundle --release

# Fichier généré :
# build/app/outputs/bundle/release/app-release.aab
```

## 📱 5. CAPTURER SCREENSHOTS

```bash
flutter run --release
# Prendre 2-8 captures d'écran
```

## 📤 6. PRÉPARER PACKAGE AMI

```powershell
# Windows PowerShell
cd C:\Users\rayen\Desktop
New-Item -ItemType Directory -Path "ImmoTunisie_Deploy" -Force

# Copier fichiers
$src = "App_Immobilier"
$dst = "ImmoTunisie_Deploy"

Copy-Item "$src\frontend\build\app\outputs\bundle\release\app-release.aab" $dst
Copy-Item "$src\frontend\android\immotunisie-upload-key.jks" $dst
Copy-Item "$src\GUIDE_FOR_DEPLOYER.md" $dst
Copy-Item "$src\PRIVACY_POLICY.md" $dst
# + Copier assets (logo, feature graphic, screenshots)

# Compresser
Compress-Archive -Path $dst -DestinationPath "ImmoTunisie_Deploy.zip" -Force
```

## ✅ VÉRIFICATIONS

```bash
# Vérifier keystore
keytool -list -v -keystore immotunisie-upload-key.jks

# Vérifier AAB généré
dir frontend\build\app\outputs\bundle\release\
```

## 🔗 LIENS UTILES

- Canva (logo) : https://www.canva.com
- Play Console : https://play.google.com/console
- GitHub Pages : https://pages.github.com
- Netlify Drop : https://app.netlify.com/drop

## 📖 LIRE LES GUIDES

```bash
notepad START_HERE.md
notepad QUICK_START_DEPLOYMENT.md
notepad PLAY_STORE_DEPLOYMENT_GUIDE.md
```

## 🆘 PROBLÈME ?

Lire : `PLAY_STORE_DEPLOYMENT_GUIDE.md` section "Troubleshooting"
