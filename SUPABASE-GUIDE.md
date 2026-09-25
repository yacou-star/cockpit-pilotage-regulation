# 🔐 Cockpit avec comptes utilisateurs (Supabase Auth)

Chaque utilisateur **crée son compte** (e-mail + mot de passe), ne voit que **ses** données, et un rôle **administrateur** peut consulter et gérer l'ensemble. Le tout premier compte créé devient automatiquement administrateur — ce sera le vôtre.

**Vue d'ensemble :** créer le projet Supabase → exécuter `supabase/schema.sql` → coller URL + clé dans le cockpit → créer votre compte. Comptez **15 minutes**, tout est gratuit.

---

## 1. Créer le projet Supabase (~3 min)

1. **https://supabase.com** → **Start your project** → connexion **avec GitHub** (votre compte yacou-star fonctionne directement)
2. **New project** :
   - Name : `cockpit-pilotage`
   - Database Password : générez-le et **gardez-le précieusement** (administration directe de la base uniquement — le cockpit n'en a pas besoin)
   - Region : **West EU (Paris)** si proposée
3. Attendez ~2 minutes

## 2. Exécuter le schéma (~2 min)

1. **SQL Editor** → **New query**
2. Ouvrez **`supabase/schema.sql`**, copiez **tout**, collez, **Run** → `Success. No rows returned`
3. Vérification : **Table Editor** → tables **`profiles`** et **`cockpit_state`** présentes

> Cette version **remplace** l'ancienne (partagée) : si vous aviez déjà exécuté l'ancien `schema.sql`, le nouveau script supprime et recrée `cockpit_state` — les données partagées d'alors ne sont pas transférables automatiquement (elles appartenaient à tout le monde, pas à un compte).

## 3. Autoriser le site à ouvrir des comptes (~1 min)

Le site est servi depuis `https://yacou-star.github.io` — il faut le déclarer :

1. **Authentication → URL Configuration → Redirect URLs** → ajoutez :
   `https://yacou-star.github.io/*`
2. **Authentication → Providers → Email** → vérifiez qu'il est **activé** (par défaut oui)

*(Pour tester en local, ajoutez aussi `http://127.0.0.1:*` dans les Redirect URLs.)*

## 4. Connecter le cockpit (~2 min)

1. Ouvrez https://yacou-star.github.io/cockpit-pilotage-regulation/ → **👤 Compte**
2. Dépliez **Configuration du projet Supabase** → collez l'**URL** (Settings → API → Project URL) et la **clé publique (anon)** — une seule fois par navigateur
3. **Créer mon compte** : votre e-mail + un mot de passe (8 caractères min.)
4. Selon la configuration Supabase :
   - **Sans confirmation e-mail** (par défaut) : vous êtes connecté immédiatement — et comme premier compte, vous êtes **administrateur**
   - **Avec confirmation e-mail** : cliquez le lien reçu, puis connectez-vous

## 5. Vérifier l'isolation des comptes (~3 min)

1. Créez un **2ᵉ compte** (autre e-mail, même navigateur après déconnexion, ou navigation privée) → il est simple **Utilisateur**
2. Sur ce compte : saisissez des données différentes → **Enregistrer dans le cloud** → déconnectez-vous
3. Reconnectez-vous avec le **1ᵉʳ compte** : vos données sont les vôtres — pas celles du 2ᵉ
4. **🛡️ Administration** en bas de la fenêtre Compte : les 2 comptes apparaissent, avec leurs dates de sauvegarde

## 6. Pouvoirs de l'administrateur

| Action | Comment |
|---|---|
| **Voir les données** d'un compte | Panneau admin → **Voir** — les données s'affichent dans le cockpit (bandeau « Vue administrateur »), bouton d'enregistrement verrouillé pour ne pas écraser ses données |
| **Supprimer les données** d'un compte (il garde son login) | Panneau admin → **Vider** |
| **Promouvoir / rétrograder** un compte | Panneau admin → **Promouvoir admin** / **Rétrograder** |
| **Supprimer définitivement un compte** | Supabase → **Authentication → Users** → ⋯ → **Delete user** → toutes les données du cockpit sont effacées automatiquement (cascade) |
| **Revenir à ses propres données** | Bandeau jaune → **↩️ Revenir à mes données** |

## Utilisation au quotidien

- Chaque utilisateur : 👤 Compte → Se connecter. Au démarrage, le cockpit **recharge automatiquement** la dernière sauvegarde de son compte.
- **⬆️ Enregistrer dans le cloud** quand vous avez fini de travailler ; **⬇️ Recharger mes données** pour revenir à la dernière sauvegarde.
- Sans compte, le cockpit reste utilisable **hors ligne** — les données ne quittent pas le navigateur (boutons JSON inchangés).

## Sécurité — ce qui est réellement protégé

- **Isolation stricte** : un utilisateur ne peut lire ni écrire que dans ses propres données — c'est la base de données elle-même (RLS) qui l'impose, pas seulement l'interface.
- **Admin = administration**, pas espionnage silencieux : toute consultation des données d'un utilisateur se voit (bandeau + date « Données »).
- L'admin peut **promouvoir** qui il veut ; il ne peut pas se rétrograder lui-même par erreur (verrou sur sa propre ligne).
- Le mot de passe est géré par Supabase Auth (hachage, sessions, expiration, rafraîchissement automatique).
- **Limites connues** : tout **admin** peut consulter les données de tous (c'est le principe demandé) ; n'importe qui peut **créer un compte** (email de confirmation recommandé pour filtrer — voir ci-dessous) ; la clé `anon` reste publique par conception.

## Options recommandées

- **Confirmation e-mail obligatoire** (filtre les comptes fantaisistes) : Authentication → Providers → Email → **Confirm email** activé.
- **Limiter les inscriptions** : Authentication → Providers → Email → désactiver « Allow new users to sign up » une fois l'équipe créée — les connexions restent possibles, plus personne ne peut s'auto-inscrire.

## Dépannage

| Symptôme | Cause | Solution |
|---|---|---|
| « Invalid API key » / erreur 401 | Clé ou URL erronée | Ressaisir depuis Settings → API (clé complète, sans espace) |
| « User already registered » | Compte déjà créé | Se connecter plutôt que créer |
| Compte créé mais connexion impossible | Confirmation e-mail activée | Valider le lien reçu puis se connecter |
| « Database error saving new user » / profil manquant | Trigger non créé | Ré-exécuter tout `schema.sql` |
| L'admin ne voit pas le panneau | Il n'est pas le 1ᵉʳ compte | Un autre admin peut le promouvoir, ou SQL Editor : `update public.profiles set role='admin' where email='...';` |
| « Database error » à la connexion d'un compte existant | Ancien format de table (version partagée) | Ré-exécuter `schema.sql` (il recrée les tables au nouveau format) |

## Fichiers de cette intégration

- `supabase/schema.sql` — schéma complet (profils, rôles, isolation, cascade)
- `github-pages-deploy/index.html` — l'app avec le module 👤 Compte (déployée sur GitHub Pages)
- Ce guide
