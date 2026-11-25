Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resources :users, only: %i[new create]

  resources :events do
    resource :registration, only: %i[create destroy]
  end
  resource :my_page, only: :show

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  root "events#index"
end
