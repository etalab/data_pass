Rails.application.routes.draw do
  root 'pages#home'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')

  get '/dashboard', to: 'dashboard#index'
end
