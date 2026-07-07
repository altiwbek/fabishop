Rails.application.routes.draw do
  # ---- Authentication (admin/staff) ----
  resource :session
  resources :passwords, param: :token

  # ---- Storefront (public) ----
  root "home#index"

  resources :products, only: [ :index, :show ] do
    resources :reviews, only: [ :create ], module: :products
    post :quick_view, on: :member
  end
  resources :categories, only: [ :index, :show ]
  resources :collections, only: [ :index, :show ]
  resources :posts, only: [ :index, :show ], path: "blog"

  get "search", to: "search#index", as: :search

  # Cart
  get    "cart",              to: "cart#show",   as: :cart
  post   "cart/:product_id",  to: "cart#add",    as: :cart_add
  patch  "cart/:product_id",  to: "cart#update", as: :cart_item
  delete "cart/:product_id",  to: "cart#remove", as: :cart_remove
  delete "cart",              to: "cart#clear",  as: :cart_clear

  # Wishlist
  get    "wishlist",             to: "wishlist#show",   as: :wishlist
  post   "wishlist/:product_id", to: "wishlist#toggle", as: :wishlist_toggle
  delete "wishlist/:product_id", to: "wishlist#remove", as: :wishlist_remove

  # Checkout & orders
  get  "checkout", to: "checkout#new",    as: :checkout
  post "checkout", to: "checkout#create"
  get  "orders/:token", to: "orders#show", as: :order

  # Order tracking (guest lookup by number + email)
  get  "track", to: "order_tracking#new",    as: :track
  post "track", to: "order_tracking#create"

  # Dev inbox for outgoing emails
  mount LetterOpenerWeb::Engine, at: "/letters" if Rails.env.development?

  # Recently viewed (Turbo Frame lazy content)
  get "recently_viewed", to: "recently_viewed#show", as: :recently_viewed

  # ---- Admin CRM ----
  namespace :admin do
    root "dashboard#index"

    resources :products do
      member do
        patch :toggle_published
      end
      collection do
        patch :bulk
      end
      resources :product_images, only: [ :create, :destroy, :update ], path: "images"
    end
    resources :categories
    resources :brands
    resources :collections do
      resources :collection_products, only: [ :create, :destroy, :update ], path: "items"
    end
    resources :posts
    resources :slides
    resources :reviews, only: [ :index, :update, :destroy ]
    resources :orders, only: [ :index, :show, :update ]
    resources :users
  end

  # Reveal health status on /up.
  get "up" => "rails/health#show", as: :rails_health_check
end
