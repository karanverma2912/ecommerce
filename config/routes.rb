Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "api/v1/products#index"

  namespace :api do
    namespace :v1 do
      # Authentication routes
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      post "auth/refresh", to: "auth#refresh"
      post "auth/logout", to: "auth#logout"

      # Products routes
      resources :products, only: [ :index, :show, :create, :update, :destroy ] do
        collection do
          get :search
        end
      end

      # Categories routes
      resources :categories, only: [ :index, :show, :create, :update, :destroy ]

      # Cart routes
      get "cart", to: "carts#show"
      post "cart/items", to: "carts#add_item"
      patch "cart/items/:id", to: "carts#update_item"
      delete "cart/items/:product_id", to: "carts#remove_item"
      delete "cart/clear", to: "carts#clear"

      # Orders routes
      resources :orders, only: [ :index, :show, :create ] do
        member do
          patch :update_status
        end
      end

      # Reviews routes
      resources :products, only: [] do
        resources :reviews, only: [ :index, :create, :destroy ] do
          resources :comments, only: [ :create, :destroy ]
        end
      end

      # Wishlist routes
      get "wishlist", to: "wishlists#index"
      post "wishlist", to: "wishlists#add"
      delete "wishlist/:product_id", to: "wishlists#remove"

      # Webhooks routes (for Stripe)
      post "webhooks/stripe", to: "webhooks#stripe"
    end
  end

  # mount Rswag::Ui::Engine => "/api-docs"
  # mount Rswag::Api::Engine => "/api-docs"
end
