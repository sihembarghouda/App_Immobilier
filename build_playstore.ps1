#!/usr/bin/env pwsh
# Script de Build pour ImmoTunisie - Google Play Store

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  IMMOTUNISIE - BUILD PLAY STORE" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Variables
$frontendPath = "C:\Users\rayen\Desktop\App_Immobilier\frontend"
$aabPath = "$frontendPath\build\app\outputs\bundle\release\app-release.aab"
$keystorePath = "$frontendPath\android\immotunisie-upload-key.jks"

# Vérifier si on est dans le bon répertoire
if (-not (Test-Path $frontendPath)) {
    Write-Host "❌ Erreur : Dossier frontend introuvable!" -ForegroundColor Red
    Write-Host "   Chemin : $frontendPath" -ForegroundColor Yellow
    exit 1
}

Set-Location $frontendPath

Write-Host "📂 Répertoire : $frontendPath" -ForegroundColor Green
Write-Host ""

# ÉTAPE 1 : Vérifier logo
Write-Host "1️⃣  Vérification du logo..." -ForegroundColor Yellow
$logoPath = "assets\images\app_logo.png"

if (-not (Test-Path $logoPath)) {
    Write-Host "⚠️  ATTENTION : Logo manquant !" -ForegroundColor Red
    Write-Host "   Créez un logo 1024x1024 et enregistrez-le dans:" -ForegroundColor Yellow
    Write-Host "   $frontendPath\$logoPath" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "   Voulez-vous continuer sans logo ? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
} else {
    Write-Host "✅ Logo trouvé : $logoPath" -ForegroundColor Green
}

Write-Host ""

# ÉTAPE 2 : Vérifier keystore
Write-Host "2️⃣  Vérification du keystore..." -ForegroundColor Yellow

if (-not (Test-Path $keystorePath)) {
    Write-Host "⚠️  ATTENTION : Keystore manquant !" -ForegroundColor Red
    Write-Host "   Vous devez créer un keystore pour signer l'application." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Commande à exécuter :" -ForegroundColor Cyan
    Write-Host "   cd android" -ForegroundColor White
    Write-Host "   keytool -genkey -v -keystore immotunisie-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload" -ForegroundColor White
    Write-Host ""
    exit 1
} else {
    Write-Host "✅ Keystore trouvé : $keystorePath" -ForegroundColor Green
}

Write-Host ""

# ÉTAPE 3 : Clean
Write-Host "3️⃣  Nettoyage des builds précédents..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors du nettoyage" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Nettoyage terminé" -ForegroundColor Green
Write-Host ""

# ÉTAPE 4 : Get dependencies
Write-Host "4️⃣  Récupération des dépendances..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors de la récupération des dépendances" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Dépendances installées" -ForegroundColor Green
Write-Host ""

# ÉTAPE 5 : Build AAB
Write-Host "5️⃣  Build Android App Bundle (AAB)..." -ForegroundColor Yellow
Write-Host "   Cela peut prendre quelques minutes..." -ForegroundColor Cyan
Write-Host ""

flutter build appbundle --release

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Erreur lors du build !" -ForegroundColor Red
    Write-Host ""
    Write-Host "Vérifications à faire :" -ForegroundColor Yellow
    Write-Host "1. Vérifiez que key.properties existe dans android/" -ForegroundColor White
    Write-Host "2. Vérifiez les mots de passe dans key.properties" -ForegroundColor White
    Write-Host "3. Vérifiez que build.gradle.kts contient la config signingConfigs" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "✅ Build terminé avec succès !" -ForegroundColor Green
Write-Host ""

# ÉTAPE 6 : Vérifier fichier généré
if (Test-Path $aabPath) {
    $fileSize = (Get-Item $aabPath).Length / 1MB
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "  ✅ APPLICATION PRÊTE !" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📦 Fichier généré :" -ForegroundColor Cyan
    Write-Host "   $aabPath" -ForegroundColor White
    Write-Host ""
    Write-Host "📊 Taille : $([math]::Round($fileSize, 2)) MB" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🚀 Prochaines étapes :" -ForegroundColor Yellow
    Write-Host "   1. Créer assets Play Store (logo 512x512, feature graphic)" -ForegroundColor White
    Write-Host "   2. Capturer screenshots de l'application" -ForegroundColor White
    Write-Host "   3. Héberger PRIVACY_POLICY.md en ligne" -ForegroundColor White
    Write-Host "   4. Créer compte Google Play Console (25 USD)" -ForegroundColor White
    Write-Host "   5. Uploader app-release.aab" -ForegroundColor White
    Write-Host ""
    Write-Host "📖 Documentation complète : PLAY_STORE_DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "❌ Fichier AAB introuvable à : $aabPath" -ForegroundColor Red
    exit 1
}

# Option : Ouvrir l'explorateur
$openFolder = Read-Host "Voulez-vous ouvrir le dossier du fichier ? (y/n)"
if ($openFolder -eq "y") {
    Start-Process explorer.exe -ArgumentList "/select,`"$aabPath`""
}

Write-Host ""
Write-Host "✨ Terminé ! Bonne chance avec votre publication ! 🎉" -ForegroundColor Green
Write-Host ""
