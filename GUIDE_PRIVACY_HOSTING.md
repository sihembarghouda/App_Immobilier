# 🌐 GUIDE: Héberger la Privacy Policy

## ⚠️ IMPORTANT
Google Play Store EXIGE une privacy policy accessible publiquement en ligne pour toute app qui collecte des données personnelles.

Votre app collecte:
- 📍 Localisation GPS
- 📸 Photos
- 👤 Infos personnelles (nom, email, téléphone)
- 💬 Messages

→ Privacy policy = OBLIGATOIRE

---

## OPTION 1: GitHub Pages (GRATUIT, Recommandé)

### Avantages:
✅ Gratuit à vie
✅ URL stable
✅ Facile à mettre à jour
✅ Pas besoin de serveur

### Étapes:

#### 1. Créer un repo GitHub public

```powershell
# Si Git n'est pas configuré:
git config --global user.name "Votre Nom"
git config --global user.email "votre@email.com"

# Créer le repo localement
cd C:\Users\rayen\Desktop\App_Immobilier
git init
git add .
git commit -m "Initial commit - ImmoTunisie app"
```

#### 2. Créer le repo sur GitHub.com

1. Aller sur https://github.com/new
2. Nom du repo: `App_Immobilier` ou `ImmoTunisie`
3. ✅ Public (requis pour GitHub Pages gratuit)
4. Créer le repository

#### 3. Pusher votre code

```powershell
git remote add origin https://github.com/VOTRE_USERNAME/App_Immobilier.git
git branch -M main
git push -u origin main
```

#### 4. Activer GitHub Pages

1. Sur GitHub, aller dans votre repo
2. Settings → Pages (menu gauche)
3. Source: `Deploy from a branch`
4. Branch: `main` → Folder: `/ (root)`
5. Save

#### 5. Attendre 2-5 minutes

GitHub va déployer votre site. L'URL sera:
```
https://VOTRE_USERNAME.github.io/App_Immobilier/PRIVACY_POLICY.md
```

#### 6. Tester l'URL

Ouvrez l'URL dans un navigateur. Si ça affiche le contenu brut markdown, ajoutez ce fichier:

```powershell
# Créer index.html qui redirige vers la privacy policy formatée
@"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ImmoTunisie - Politique de Confidentialité</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        h1 { color: #2196F3; }
        h2 { color: #333; margin-top: 30px; }
        p { line-height: 1.6; }
    </style>
</head>
<body>
    <div id="content"></div>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <script>
        fetch('PRIVACY_POLICY.md')
            .then(response => response.text())
            .then(text => {
                document.getElementById('content').innerHTML = marked.parse(text);
            });
    </script>
</body>
</html>
"@ | Out-File -FilePath "privacy.html" -Encoding UTF8

git add privacy.html
git commit -m "Add privacy policy HTML viewer"
git push
```

Maintenant utilisez:
```
https://VOTRE_USERNAME.github.io/App_Immobilier/privacy.html
```

---

## OPTION 2: Netlify Drop (ULTRA RAPIDE, Gratuit)

### Avantages:
✅ Déploiement en 30 secondes
✅ Pas besoin de Git
✅ Drag & drop
✅ Gratuit

### Étapes:

1. Convertir PRIVACY_POLICY.md en HTML:

```powershell
$markdown = Get-Content "C:\Users\rayen\Desktop\App_Immobilier\PRIVACY_POLICY.md" -Raw
@"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ImmoTunisie - Politique de Confidentialité</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 40px 20px; background: #f5f5f5; }
        .container { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2196F3; border-bottom: 3px solid #2196F3; padding-bottom: 15px; }
        h2 { color: #333; margin-top: 35px; border-left: 4px solid #2196F3; padding-left: 15px; }
        p, li { line-height: 1.8; color: #555; }
        ul { padding-left: 25px; }
        .footer { text-align: center; margin-top: 50px; color: #999; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <pre style="white-space: pre-wrap; font-family: inherit;">$markdown</pre>
    </div>
    <div class="footer">
        <p>ImmoTunisie - Dernière mise à jour: $(Get-Date -Format 'dd/MM/yyyy')</p>
    </div>
</body>
</html>
"@ | Out-File -FilePath "C:\Users\rayen\Desktop\App_Immobilier\privacy.html" -Encoding UTF8

Write-Host "`n✅ HTML créé: privacy.html" -ForegroundColor Green
```

2. Aller sur https://app.netlify.com/drop

3. Drag & drop le fichier `privacy.html`

4. Netlify vous donne une URL instantanée:
   ```
   https://random-name-123456.netlify.app/privacy.html
   ```

5. (Optionnel) Personnaliser l'URL:
   - Site settings → Change site name
   - Exemple: `immotunisie-privacy.netlify.app`

---

## OPTION 3: Hébergement Propre (Si vous avez un site web)

Si vous avez déjà un domaine/hébergement:

1. Upload `PRIVACY_POLICY.md` ou `privacy.html` via FTP
2. Accéder via: `https://votre-site.com/privacy.html`

---

## OPTION 4: Google Sites (Gratuit, Facile)

1. Aller sur https://sites.google.com/new
2. Créer un nouveau site
3. Coller le contenu de PRIVACY_POLICY.md
4. Publier
5. Obtenir l'URL publique

---

## RECOMMANDATION FINALE

👉 **Netlify Drop** = Le plus rapide (2 minutes)
👉 **GitHub Pages** = Le plus stable/professionnel (10 minutes)

---

## APRÈS HÉBERGEMENT

1. Notez l'URL obtenue
2. Testez-la dans un navigateur incognito
3. Ajoutez l'URL dans CREDENTIALS.txt:

```
PRIVACY POLICY URL:
https://votre-url-ici.com/privacy.html
```

4. Cette URL sera ajoutée dans Play Console lors de la soumission

---

## ⚠️ NOTE IMPORTANTE

L'URL de la privacy policy:
- DOIT être accessible sans authentification
- DOIT être HTTPS (pas HTTP)
- DOIT rester active tant que l'app est sur le Play Store
- Peut être mise à jour, mais l'URL doit rester la même

---

## SCRIPTS AUTOMATIQUES

### Créer privacy.html avec style

```powershell
cd C:\Users\rayen\Desktop\App_Immobilier
.\create_privacy_html.ps1
```

Script inclus dans le projet!
