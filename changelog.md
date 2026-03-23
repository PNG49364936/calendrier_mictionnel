# Changelog - Calendrier Mictionnel

## 2026-02-12 - Version initiale

### Structure (Agent Init)
- Application Rails 7.1.6 avec Ruby 3.2.2, SQLite3, Bootstrap 5
- Migrations: tables `journee_observations` et `entrees`
- Modeles avec associations has_many/belongs_to

### Back-end (Agent Back-end)
- Controleurs: JourneeObservationsController (CRUD), EntreesController (CRUD nested), ResultatsController (index, pdf)
- Routes RESTful avec resources imbriquees
- Validations modeles (presence, uniqueness, inclusion, length)
- Methodes de calcul: total_boissons, total_urine, en_cours?
- Generation PDF avec Prawn et prawn-table

### Front-end (Agent Front-end)
- Layout Bootstrap 5 avec navbar, footer, flash messages
- Interface ergonomique pour patients ages (grande police, gros boutons, contraste eleve)
- Page accueil avec boutons "Nouveau formulaire", "Formulaire en cours", "Resultats"
- Tableaux style Excel pour les entrees et resultats
- Menus deroulants pour urgenturies et fuites
- Selection de dates multiples pour les resultats
- Design responsive (tablette/mobile)

### Tests (Agent Test)
- 53 tests, 113 assertions, 0 echecs, 0 erreurs
- Tests modeles (27 tests): validations, associations, methodes metier
- Tests controleurs (24 tests): CRUD journees, entrees, resultats
- Tests integration (3 tests): workflow complet, multi-jours, fermeture journee

### Bugs corriges par l'Agent Test
1. Bug vue edit journee: crash si date_observation nil (ajout operateur safe navigation)
2. Bug controleur resultats/pdf: dates vides non filtrees (ajout reject blank)
3. Compatibilite minitest: pin a ~> 5.25 pour Rails 7.1.6
