# Champion Optiquizz – version site web

Même contenu que l’application iOS, en site web (HTML/CSS/JS) :

- **Accueil** : liens vers PDM, ETSO, Analyse de la vision, Optique géométrique, Semantix.
- **PDM, Vision, Optique** : quiz avec questions à choix multiples (points selon difficulté).
- **ETSO** : quiz théorique (lentilles, rayons, images).
- **Semantix** : mot du jour (déterminé par la date), propositions avec indice de « chaleur ».

## Déploiement Netlify

- Pour publier **ce dossier** (version complète du site) : dans la racine du dépôt, éditez `netlify.toml` et mettez `publish = "web-app"`.
- Pour garder la simple page vitrine : laissez `publish = "web"`.

## Données

Les questions sont dans `data/` (JSON). Vous pouvez enrichir les fichiers `pdm.json`, `vision.json`, `optique.json`, `etso.json` et `semantix-words.json` sans toucher au code.
