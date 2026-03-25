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
- Prawn / Prawn-table (génération PDF)

#### Affichage des résultats
- pour affichage, le patient pourra selectioner un jour précis ou des périodes de jour.
  exemple : si le patient a renseigné les données le 10 juin, le 12 juin, le 15 juin, le 17 juin, il doit pouvoir sélectionner au choix, seulement 10 juin ou 10 juin et 12 juin, ou 10, 15, 17 juin.
  Affichage sous forme de tableau excell
  - total des volumes "boissons" et volumes urinés.
  il doit y avoir obligatoirement un total par jour et si plusieurs jours un total global.
  Les résultas doivent être imprimables sous forme pdf
  L'agent init fera une synthèse courte des tests.

## Structure

### Base de donnees (SQLite3)

#### Table `journee_observations`
| Colonne            | Type     | Contraintes |
|--------------------|----------|-------------|
| id                 | integer  | PK, auto    |
| date_observation   | date     | NOT NULL    |
| heure_lever        | time     |             |
| heure_coucher      | time     |             |
| created_at         | datetime | NOT NULL    |
| updated_at         | datetime | NOT NULL    |

#### Table `entrees`
| Colonne                | Type     | Contraintes          |
|------------------------|----------|----------------------|
| id                     | integer  | PK, auto             |
| journee_observation_id | integer  | NOT NULL, FK         |
| heure                  | time     | NOT NULL             |
| volume_boisson         | integer  |                      |
| volume_urine           | integer  |                      |
| urgenturies            | string   |                      |
| fuites                 | string   |                      |
| commentaires           | string   | limit: 10            |
| intervalle_mictionnel  | integer  | calculé auto (min)   |
| created_at             | datetime | NOT NULL             |
| updated_at             | datetime | NOT NULL             |

### Modeles
- `JourneeObservation` (`app/models/journee_observation.rb`) -- has_many :entrees, dependent: :destroy ; méthode `recalculer_intervalles!` pour calculer automatiquement l'intervalle entre mictions
- `Entree` (`app/models/entree.rb`) -- belongs_to :journee_observation ; callback after_save/after_destroy pour recalculer les intervalles mictionnels
- **Intervalle mictionnel** : calculé automatiquement en minutes entre chaque miction (entrées ayant un volume_urine > 0). La 1ère miction du jour n'a pas d'intervalle (nil). Stocké dans la colonne `intervalle_mictionnel` de la table `entrees`.

### Controlleurs
- `JourneeObservationsController` (`app/controllers/journee_observations_controller.rb`) -- CRUD journées
- `EntreesController` (`app/controllers/entrees_controller.rb`) -- CRUD entrées (imbriqué dans journee_observations)
- `ResultatsController` (`app/controllers/resultats_controller.rb`) -- affichage et export PDF des résultats

### Routes
- `root` -> `journee_observations#index`
- `resources :journee_observations` avec `resources :entrees` imbriquées (sauf index/show)
- `GET /resultats` -> `resultats#index`
- `GET /resultats/pdf` -> `resultats#pdf`

### Fichiers cles
- `db/schema.rb` -- schema de la base de donnees
- `db/migrate/` -- fichiers de migration
- `app/assets/stylesheets/application.bootstrap.scss` -- point d'entree Bootstrap 5
- `app/views/layouts/application.html.erb` -- layout principal
- `config/routes.rb` -- routes de l'application
- `Gemfile` -- dependances Ruby
- `package.json` -- dependances JavaScript/CSS (Bootstrap, Sass, etc.)

##### Organisarion de la création de l'app.
Création d'une team de 4 agents avec les roles suivants

# Agent Init et coordination (utilise sonnet)
  Va créer la structure de l'app et informera les autres agents quand fait.
  Mettra à jour Claude.md
  Lorsque des modifications seront à faire (seront dans change.md), informera agent back-end ou front-end
  Une fois modifications éffectuées, mettre à jour changelog.md et effacera change.MD
  Hors la création de la structure, ne code pas l'app
  une fois les test 

# Agent back-end.(utilise opus 4.6)
  - gére les controlleurs, les models, les routes, etc. 

# Agent front-end.(utilise sonnet);
  - mets en place interface agréable
  - doit être ergonomique
  
# Agent test.(utlise sonnet). 
  - fait les tests focntionnels et apporte les corrections aux bugs.
  - confirmera à l'agent init les résultats des tests