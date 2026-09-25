# Cockpit Pilotage & Régulation — GitHub Pages

Application cockpit autonome (un seul fichier `index.html`, aucune dépendance externe), prête à être servie par GitHub Pages.

## 🚀 Publication initiale

> Prérequis : un compte GitHub. Les commandes ci-dessous se font depuis le dossier `github-pages-deploy`.

**1. Créer le dépôt distant**

- Ouvrez https://github.com/new
- Nom du dépôt : `cockpit-pilotage-regulation`
- Laissez **toutes** les cases d'initialisation décochées (pas de README, pas de licence, pas de .gitignore)
- Visibilité : **Private** convient très bien (GitHub Pages fonctionne sur les dépôts privés, offre gratuite incluse)
- Cliquez **Create repository** — ne suivez pas les commandes d'exemple affichées ensuite, tout est déjà fait ici

**2. Connecter et pousser**

```bash
git remote add origin https://github.com/<VOTRE-UTILISATEUR>/cockpit-pilotage-regulation.git
git push -u origin main
```

À la demande d'identifiants :
- **Navigateur** (recommandé) : si une fenêtre s'ouvre automatiquement, connectez-vous — c'est l'OAuth de Git Credential Manager.
- **Terminal** : coller un **PAT (personal access token)** comme mot de passe. Création : https://github.com/settings/tokens?type=beta → *Generate new token* → 90 jours minimum, cochez **Contents: Read and write**. Un simple mot de passe GitHub ne fonctionne pas pour git push.

**3. Activer GitHub Pages**

- Sur le dépôt : **Settings → Pages** (menu de gauche)
- *Build and deployment* → Source : **Deploy from a branch**
- Branch : `main` / folder : `/(root)` → **Save**

L'URL `https://<VOTRE-UTILISATEUR>.github.io/cockpit-pilotage-regulation/` est active en **1 à 2 minutes** (première publication).

## 🔄 Mettre à jour l'application

L'app évolue (le fichier source vit dans `../Pilotage_Regulation_App_redesign.html`). Mise à jour en 2 commandes :

```bash
cp ../Pilotage_Regulation_App_redesign.html index.html
git add index.html && git commit -m "Mise a jour du cockpit" && git push
```

Le site en ligne se rafraîchit automatiquement (comptez ~1 minute). Astuce : forcez un rechargement dans le navigateur avec **Cmd+Shift+R** — Pages sert avec un cache court mais réel.

## 🧩 Intégration Google Sites

1. Google Sites → **Insertion → Intégrer → Par URL** → collez l'URL Pages ci-dessus
2. Étirez le bloc d'intégration en pleine largeur/hauteur — le cockpit a besoin de hauteur pour ses onglets
3. Publiez

⚠️ Dans l'iframe Google Sites, chaque utilisateur garde ses propres données (Export/Import JSON, par navigateur). Pas de partage centralisé des données : pour cela, voir la piste SharePoint dans `../pilotage-regulation-spfx/`.

## 📁 Contenu du dépôt

| Fichier | Rôle |
|---|---|
| `index.html` | L'application cockpit complète, autonome (178 Ko) |
| `.nojekyll` | Désactive le post-traitement Jekyll de GitHub Pages (inutile ici, évite tout risque sur les `_`-fichiers) |
| `README.md` | Ce fichier |
