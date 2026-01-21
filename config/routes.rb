Rails.application.routes.draw do
  # 1. Routes pour l'authentification (Devise)
  devise_for :users

  # 2. La page d'accueil (root)
  root "products#index"

  # 3. Routes pour les produits
  # Cette SEULE ligne crée toutes les routes (index, show, new, edit, create, update, destroy)
  resources :products

  # --- Routes techniques (Rails 7.1+) ---
  get "up" => "rails/health#show", as: :rails_health_check
end