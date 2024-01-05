Rails.application.routes.draw do
  root 'pages#home'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')

  get 'compte/deconnexion', to: 'sessions#destroy', as: :signout

  get '/tableau-de-bord', to: 'dashboard#index', as: :dashboard

  get '/compte', to: 'profile#edit', as: :profile
  patch '/compte', to: 'profile#update'

  scope(path_names: { new: 'nouveau' }) do
    resources :authorization_requests, only: %w[index show], path: 'habilitations'
    get '/habilitations/:id/nouveau', to: 'authorization_requests#new', as: :new_authorization_request

    scope(path: 'formulaires/:form_uid') do
      resources :authorization_request_forms, only: %w[new create show update], path: 'demande'

      scope 'demande/:authorization_request_id' do
        resources :build, controller: 'authorization_request_forms/build', only: %w[show update], path: 'etapes', as: 'authorization_request_form_build'
      end

      resources :authorization_request_from_templates, only: %i[index create], path: 'templates'
    end
  end

  get '/instruction', to: redirect('/instruction/demandes')

  namespace :instruction do
    resources :authorization_requests, only: %w[index show], path: 'demandes' do
      member do
        post :refuse, path: 'refuser'
      end

      resources :approve_authorization_requests, only: %w[new create], path: 'approuver', as: :approval
    end
  end
end
