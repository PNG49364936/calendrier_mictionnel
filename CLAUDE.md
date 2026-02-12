# Calendrier mictionnel

## description
App destinée à étudier le plus précisément le fonctionnement de la vessie d'un patient. il est donc demandé au patient de noter :
- jour de l observation
- heure de lever
- heure de coucher
puis le malade devra renseigner plusieurs fois par jour :
- heure---->volume boisson(ml)
- heure---->volume uriné(ml)
- urgenturies (si possibilité de choisir X. menu déroulant?)
- fuites (si possibilité de choisir X. menu déroulant)
- commentaires (environ 10 caractères)
il faudra donc un formulaire pour renseigner les données.
Le patient pourra sélectionner "nouveau formulaire" qui correspond à un nouveau jour.Il remplira donc jour de l'observation et heure de lever.
Le patient devra pouvoir selectionner aussi  "formulaire en cours" valable jusqu'à l'heure du coucher.

## Technologies
- Rails 7.1.6
- Ruby 3.2.2
- SQLite3 (base de données locale)
- Bootstrap 5 (via cssbundling-rails)

#### Affichage des résultats
- pour affichage, le patient pourra selectioner un jour précis ou des périodes de jour.
  exemple : si le patient a renseigné les données le 10 juin, le 12 juin, le 15 juin, le 17 juin, il doit pouvoir sélectionner au choix, seulement 10 juin ou 10 juin et 12 juin, ou 10, 15, 17 juin.
  Affichage sous forme de tableau excell
  - total des volumes "boissons" et volumes urinés.
  il doit y avoir obligatoirement un total par jour et si plusieurs jours un total global.
  Les résultas doivent être imprimables sous forme pdf

##### Organisarion de la création de l'app.
Création d'une team de 4 agents avec les roles suivants

# Agent Init. (utilise sonnet)
  Va créer la structure de l'app et informera les autres agents quand fait.
  Mettra à jour Claude.md
  Lorsque des modifications seront à faire (seront dans change.md), informera agent back-end ou front-end
  Une fois modifications éffectuées, mettre à jour changelog.md et effacera change.MD
  Hors la création de la structure, ne code pas l'app

# Agent back-end.(utilise opus 4.6)
  - gére les controlleurs, les models, les routes, etc.

# Agent front-end.(utilise sonnet)
  - mets en place interface agréable
  - doit être ergonomique
  
# Agent test.(utlise sonnet)
  - fait les tests focntionnels.
