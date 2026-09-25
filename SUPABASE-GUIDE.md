# 🗄️ Connecter le cockpit à Supabase (backend gratuit)

Ce guide connecte le cockpit au **cloud Supabase** : vos données (paramètres, ressources, flux, projets, activités, matrices) sont enregistrées en ligne et rechargeables depuis n'importe quel appareil, par toute l'équipe.

**Vue d'ensemble :** créer un projet Supabase → exécuter `schema.sql` → coller URL + clé dans le cockpit → enregistrer. Comptez **10 minutes**, tout est gratuit.

---

## 1. Créer le projet Supabase (~3 min)

1. Ouvrez **https://supabase.com** → **Start your project** → connectez-vous **avec GitHub** (votre compte yacou-star fonctionne directement)
2. **New project** :
   - Name : `cockpit-pilotage`
   - Database Password : générez un mot de passe et **gardez-le précieusement** (il ne sert qu'à l'administration directe de la base, le cockpit n'en a pas besoin)
   - Region : **West EU (Paris)** si proposée
3. Attendez ~2 minutes la fin du provisionnement

## 2. Créer la table (~2 min)

1. Dans le menu de gauche : **SQL Editor** → **New query**
2. Ouvrez le fichier **`supabase/schema.sql`** de ce dossier, **copiez tout** son contenu et **collez-le** dans l'éditeur
3. **Run** (ou Ctrl+Enter) → vous devez voir `Success. No rows returned`
4. Vérification : menu **Table Editor** → la table **`cockpit_state`** apparaît

## 3. Récupérer URL et clé (~1 min)

Dans **Settings → API** (menu de gauche) :
- **Project URL** : `https://xxxxxxxx.supabase.co` → c'est l'**URL du projet**
- **Project API Keys → `anon` / `public`** : la longue clé `eyJhbGciOi...` → c'est la **clé publique**

⚠️ Prenez bien la clé **anon/public** — pas la clé `service_role` qui, elle, est secrète et ne doit jamais être mise dans une page web.

## 4. Connecter le cockpit (~1 min)

1. Ouvrez le cockpit → bouton **☁️ Cloud** dans la barre du haut
2. Collez l'**URL** et la **clé publique** — statut attendu : vert « Connecté ✓ »
3. **Espace de travail** : gardez `cockpit`, ou mettez un nom par équipe (ex. `equipe-cd76`) pour séparer les jeux de données dans la même base
4. Cliquez **⬆️ Enregistrer dans le cloud** → toast « Cockpit enregistré ✓ »

## 5. Vérifier le multi-appareils

- Ouvrez le site depuis un autre navigateur/appareil → ☁️ Cloud → mêmes URL + clé + espace → **⬇️ Charger le cloud** → toutes vos données reviennent
- Dans Supabase, **Table Editor → cockpit_state** : vous voyez la ligne et sa date de mise à jour

---

## Utilisation au quotidien

| Action | Bouton |
|---|---|
| Sauvegarder votre travail | ☁️ Cloud → **Enregistrer dans le cloud** |
| Récupérer les données | ☁️ Cloud → **Charger le cloud** |
| Sauvegarde fichier (secours) | 💾 JSON (inchangé) |

La configuration (URL + clé) est mémorisée **par navigateur** — à ressaisir une seule fois par appareil. L'Export/Import JSON reste disponible en parallèle : rien n'est supprimé.

## Sécurité — ce qu'il faut savoir

- La clé `anon` est **publique par conception** : quiconque a l'URL du site peut lire/écrire les données du cockpit. C'est le même niveau de protection que le fichier JSON d'origine, mais partagé.
- Le cloisonnement se fait par **espace de travail** : deux équipes utilisant le même projet Supabase mais des espaces différents ne voient pas les données l'une de l'autre.
- Pour un vrai contrôle d'accès (authentification, un compte par personne) : activer Supabase **Auth** dans le projet et restreindre les policies — je peux le faire évoluer plus tard si le besoin arrive.

## Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| Statut rouge « Table cockpit_state introuvable » | `schema.sql` pas exécuté | Refaire l'étape 2 |
| `Erreur 401` | Clé invalide (copie partielle ?) | Recoller la clé complète depuis Settings → API |
| `Erreur 404` sur enregistrement | URL mal formée | Doit finir par `.supabase.co`, sans `/rest/v1` derrière |
| « Aucune sauvegarde cloud » au chargement | Espace de travail différent | Vérifier que le champ Espace est identique sur les deux appareils |
| Rien ne change sur l'autre appareil | Config non enregistrée sur cet appareil | Ressaisir URL + clé (mémorisées ensuite) |

## Fichiers de cette intégration

- `supabase/schema.sql` — le script à exécuter dans Supabase
- `github-pages-deploy/index.html` — l'app avec le module ☁️ intégré (déployée sur GitHub Pages)
- Ce guide
