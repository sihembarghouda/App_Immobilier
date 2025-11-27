# 🎨 GUIDE: Créer les Assets Visuels Play Store

## Fichiers requis:

### 1. Feature Graphic (1024×500 px) - REQUIS
- Format: JPG ou PNG 24-bit
- Pas de transparence
- Contenu: Nom app + tagline + visuels

### 2. High-res Icon (512×512 px) - REQUIS  
- Format: PNG 32-bit
- Transparence: optionnelle
- C'est votre logo redimensionné

### 3. Screenshots - MINIMUM 2, MAXIMUM 8
- Format: JPG ou PNG 24-bit
- Résolution minimale: 320px
- Résolution maximale: 3840px
- Ratio: Entre 16:9 et 9:16

---

## ÉTAPE 1: Créer Feature Graphic (Canva)

1. Aller sur: https://www.canva.com
2. Créer un design 1024×500 px
3. Design suggéré:
   ```
   ┌─────────────────────────────────────┐
   │  📱         IMMOTUNISIE         🏠  │
   │                                     │
   │  Trouvez votre propriété idéale     │
   │         en Tunisie                  │
   │                                     │
   │  [Petite capture d'écran de l'app]  │
   └─────────────────────────────────────┘
   ```
4. Couleurs: Bleu #2196F3 + Blanc
5. Télécharger en PNG ou JPG

---

## ÉTAPE 2: Créer High-res Icon

### Option A: Redimensionner votre logo
```powershell
# Avec PowerShell:
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("C:\Users\rayen\Desktop\App_Immobilier\frontend\assets\images\app_logo.png")
$resized = New-Object System.Drawing.Bitmap(512, 512)
$graphics = [System.Drawing.Graphics]::FromImage($resized)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.DrawImage($img, 0, 0, 512, 512)
$resized.Save("C:\Users\rayen\Desktop\App_Immobilier\icon_512.png")
$graphics.Dispose()
$img.Dispose()
$resized.Dispose()
```

### Option B: Canva
1. Ouvrir app_logo.png dans Canva
2. Redimensionner: 512×512
3. Télécharger

---

## ÉTAPE 3: Capturer Screenshots

### Méthode 1: Émulateur Android Studio
```powershell
# Lancer l'app en mode release
cd C:\Users\rayen\Desktop\App_Immobilier\frontend
flutter run --release
```

Puis capturer:
1. **Écran Home** - Vue liste des propriétés
2. **Écran Recherche** - Filtres affichés
3. **Écran Carte** - Propriétés sur la carte
4. **Écran Détails** - Détails d'une propriété
5. **Écran Messages** - Conversations
6. **Écran Favoris** - Liste favoris
7. **Écran Profile** - Profil utilisateur

### Méthode 2: Appareil Physique
- Activer "Développeur" sur Android
- Activer "Débogage USB"
- Connecter via USB
- Lancer `flutter run --release`
- Capturer avec boutons Volume- + Power

### Méthode 3: Captures d'écran manuelles
Si pas d'accès émulateur:
```powershell
# Générer des screenshots automatiques
cd frontend
flutter test integration_test/screenshot_test.dart
```

---

## ÉTAPE 4: Sauvegarder les Assets

Créer un dossier:
```powershell
New-Item -ItemType Directory -Path "C:\Users\rayen\Desktop\App_Immobilier\PlayStore_Assets"
```

Structure:
```
PlayStore_Assets/
├── feature_graphic.png (1024×500)
├── icon_512.png (512×512)
└── screenshots/
    ├── 01_home.png
    ├── 02_search.png
    ├── 03_map.png
    ├── 04_details.png
    ├── 05_messages.png
    ├── 06_favorites.png
    ├── 07_profile.png
    └── 08_filters.png
```

---

## ALTERNATIVE RAPIDE: Templates Prêts

Si manque de temps, utilisez ces outils:

1. **Previewed.app** - Screenshots mockups automatiques
2. **AppLaunchpad.com** - Générateur assets Play Store  
3. **MockUPhone.com** - Mockups gratuits
4. **Smartmockups.com** - Templates professionnels

---

## Commandes PowerShell Utiles

### Créer le dossier PlayStore_Assets
```powershell
$assetsDir = "C:\Users\rayen\Desktop\App_Immobilier\PlayStore_Assets"
New-Item -ItemType Directory -Path $assetsDir -Force
New-Item -ItemType Directory -Path "$assetsDir\screenshots" -Force
Write-Host "✅ Dossier créé: $assetsDir"
```

### Redimensionner logo en 512×512
```powershell
$scriptPath = "C:\Users\rayen\Desktop\App_Immobilier\resize_icon.ps1"
@"
Add-Type -AssemblyName System.Drawing
`$source = 'C:\Users\rayen\Desktop\App_Immobilier\frontend\assets\images\app_logo.png'
`$dest = 'C:\Users\rayen\Desktop\App_Immobilier\PlayStore_Assets\icon_512.png'
`$img = [System.Drawing.Image]::FromFile(`$source)
`$resized = New-Object System.Drawing.Bitmap(512, 512)
`$graphics = [System.Drawing.Graphics]::FromImage(`$resized)
`$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
`$graphics.DrawImage(`$img, 0, 0, 512, 512)
`$resized.Save(`$dest)
`$graphics.Dispose()
`$img.Dispose()
`$resized.Dispose()
Write-Host '✅ Icon 512×512 créé: `$dest' -ForegroundColor Green
"@ | Out-File -FilePath $scriptPath -Encoding UTF8
& $scriptPath
```

---

## Checklist Finale

- [ ] Feature graphic créé (1024×500)
- [ ] Icon 512×512 créé
- [ ] Minimum 2 screenshots capturés
- [ ] Tous les fichiers dans PlayStore_Assets/
- [ ] Fichiers vérifiés (taille, résolution)

**Temps estimé total: 30-45 minutes**
