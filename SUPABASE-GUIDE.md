# 🔐 Cockpit avec comptes utilisateurs (Supabase Auth)

Chaque utilisateur **crée son compte** (e-mail + mot de passe), ne voit que **ses** données, et un rôle **administrateur** peut consulter et gérer l'ensemble. Les administrateurs sont désignés **par e-mail** dans le script d'installation — rien n'est automatique.

**Vue d'ensemble :** créer le projet Supabase → exécuter `supabase/schema.sql` → intégrer URL + clé dans l'application → créer votre compte. Comptez **15 minutes**, tout est gratuit.

## 👥 Qui fait quoi ?

| Qui | Quoi | Quand |
|---|---|---|
| **Vous (l'organisateur)** | Créer le projet Supabase, exécuter le script, transmettre URL + clé pour intégration | **Une seule fois** |
| **Les utilisateurs** | Ouvrir le site → e-mail + mot de passe → c'est tout | À chaque besoin |

Les utilisateurs n'installent rien, ne configurent rien, ne touchent jamais à Supabase : l'URL et la clé sont **intégrées dans l'application elle-même** (constante `SUPABASE_EMBED` dans `index.html`). Ils voient uniquement un écran de connexion.

> ⚠️ Tant que la constante `SUPABASE_EMBED` n'est pas remplie, l'écran de connexion affiche une section de configuration manuelle (mode de secours). Une fois intégrée et redéployée, cette section disparaît totalement.

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
   - ⚠️ **Avant de lancer**, personnalisez la ligne marquée **`← ADMIN`** : remplacez `vous@exemple.fr` par **votre adresse e-mail** (ceux qui créeront un compte avec cet e-mail deviennent administrateurs)
3. Vérification : **Table Editor** → tables **`profiles`** et **`cockpit_state`** présentes

> Cette version **remplace** l'ancienne (partagée) : si vous aviez déjà exécuté l'ancien `schema.sql`, le nouveau script supprime et recrée `cockpit_state` — les données partagées d'alors ne sont pas transférables automatiquement (elles appartenaient à tout le monde, pas à un compte).

## 3. Autoriser le site à ouvrir des comptes (~1 min)

Le site est servi depuis `https://yacou-star.github.io` — il faut le déclarer :

1. **Authentication → URL Configuration → Redirect URLs** → ajoutez :
   `https://yacou-star.github.io/*`
2. **Authentication → Providers → Email** → vérifiez qu'il est **activé** (par défaut oui)

*(Pour tester en local, ajoutez aussi `http://127.0.0.1:*` dans les Redirect URLs.)*

## 4. Intégrer la configuration dans l'application (~2 min)

C'est l'étape qui épargne toute manipulation aux utilisateurs :

1. Dans **Settings → API** : copiez l'**URL du projet** et la clé **anon/public**
2. Dans le fichier `index.html`, remplissez la constante en tête du bloc AUTH :

```js
const SUPABASE_EMBED = {
  url: 'https://xxxxxxxx.supabase.co',   // votre URL
  key: 'eyJhbGciOi...'                   // votre clé anon
};
```

3. Redéployez (`git add index.html && git commit -m "Config intégrée" && git push`)
4. Vérification : ouvrez le site → 👤 Compte → **plus aucune section de configuration**, seulement e-mail + mot de passe

## 4bis. (Secours) Configuration manuelle par navigateur

Si la constante n'est pas remplie, chaque navigateur peut être configuré à la main via la section **Configuration du projet Supabase** de la fenêtre Compte — utile pour tester avant intégration, ou pour pointer vers un autre projet.
## 5. Créer votre compte administrateur (~1 min)

1. Ouvrez le site → **👤 Compte** → **Créer mon compte**
2. Utilisez **l'e-mail que vous avez mis dans la liste ← ADMIN** du script
3. Selon la configuration Supabase :
   - **Sans confirmation e-mail** (par défaut) : vous êtes connecté immédiatement, avec le rôle **administrateur**
   - **Avec confirmation e-mail** : cliquez le lien reçu, puis connectez-vous

## 6. Vérifier l'isolation des comptes (~3 min)

1. Créez un **2ᵉ compte** (autre e-mail, même navigateur après déconnexion, ou navigation privée) → il est simple **Utilisateur**
2. Sur ce compte : saisissez des données différentes → **Enregistrer dans le cloud** → déconnectez-vous
3. Reconnectez-vous avec le **1ᵉʳ compte** : vos données sont les vôtres — pas celles du 2ᵉ
4. **🛡️ Administration** en bas de la fenêtre Compte : les 2 comptes apparaissent, avec leurs dates de sauvegarde

## Désigner les administrateurs

Le rôle admin n'est **jamais** attribué automatiquement. Trois façons de le gérer :

- **À l'avance** (recommandé) : dans `schema.sql`, ligne `← ADMIN`, listez les e-mails : `array['moi@entreprise.fr','collegue@entreprise.fr']` puis Run. Tout compte créé avec ces e-mails naît admin.
- **Après coup** : SQL Editor → `update public.profiles set role = 'admin' where email = 'quelqu_un@exemple.fr';` — la personne voit son panneau admin à sa prochaine connexion.
- **Depuis le cockpit** : un admin existant utilise le bouton **Promouvoir admin** du panneau 🛡️.

## 7. Pouvoirs de l'administrateur

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
| L'admin ne voit pas le panneau | Son e-mail n'est pas dans la liste | SQL Editor : `update public.profiles set role='admin' where email='...';` |
| « Database error » à la connexion d'un compte existant | Ancien format de table (version partagée) | Ré-exécuter `schema.sql` (il recrée les tables au nouveau format) |

## Fichiers de cette intégration

- `supabase/schema.sql` — schéma complet (profils, rôles, isolation, cascade)
- `github-pages-deploy/index.html` — l'app avec le module 👤 Compte (déployée sur GitHub Pages)
- Ce guide
