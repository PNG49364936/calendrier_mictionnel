Rails.application.routes.draw do
  root "journee_observations#index"

  resources :journee_observations do
    resources :entrees, except: [:index, :show]
  end

  get "resultats", to: "resultats#index", as: :resultats
  get "resultats/pdf", to: "resultats#pdf", as: :resultats_pdf

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
