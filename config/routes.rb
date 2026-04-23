Rails.application.routes.draw do
  root "home#index"

  resources :rooms do
    resources :room_messages
  end

  resources :users

  get "up" => "rails/health#show", as: :rails_health_check
end
