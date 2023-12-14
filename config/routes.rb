Rails.application.routes.draw do
  root 'pages#home'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')

  get 'compte/deconnexion', to: 'sessions#destroy', as: :signout

  get '/tableau-de-bord', to: 'dashboard#index', as: :dashboard

  scope(path_names: { new: 'nouveau' }) do
    resources :authorization_request_forms, only: %w[index], path: 'formulaires'

    scope(path: 'formulaires/:form_uid') do
      resources :authorization_requests, only: %w[new create show update], path: 'demande' do
        resources :build, controller: 'authorization_requests/build', only: %w[show update], path: 'etapes'
      end

      resources :authorization_request_from_templates, only: %i[index create], path: 'templates'
    end
  end
end
