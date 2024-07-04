Rails.application.routes.draw do
  root 'pages#home'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')

  if Rails.env.development?
    get 'local-sign-in', to: 'authenticated_user#bypass_login'
  end

  get 'compte/deconnexion', to: 'sessions#destroy', as: :signout

  get '/tableau-de-bord', to: 'dashboard#index', as: :dashboard
  get '/tableau-de-bord/:id', to: 'dashboard#show', as: :dashboard_show

  get '/compte', to: 'profile#edit', as: :profile
  patch '/compte', to: 'profile#update'

  patch '/settings/notifications', to: 'notifications_settings#update', as: :notifications_settings

  scope(path_names: { new: 'nouveau', edit: 'modifier' }) do
    resources :authorization_requests, only: %w[show], path: 'demandes' do
      resources :messages, only: %w[index create], path: 'messages'
      resources :archive_authorization_requests, only: %w[new create], path: 'archiver', as: :archive
      resources :blocks, only: %w[edit update], path: 'blocs', controller: 'authorization_requests/blocks'
    end

    resources :authorization_definitions, path: 'demandes', only: :index

    scope 'demandes/:authorization_definition_id', module: :authorization_definitions  do
      resources :forms, only: %w[index], path: 'formulaires', as: :authorization_definition_forms
    end

    get '/demandes/:id/nouveau', to: 'authorization_requests#new', as: :new_authorization_request

    scope(path: 'formulaires/:form_uid') do
      resources :authorization_request_forms, only: %w[new create show update], path: 'demande' do
        collection do
          get :start, path: 'commencer'
        end

        member do
          get :summary, as: :summary, path: 'résumé'
        end
      end

      scope 'demande/:authorization_request_id' do
        resources :build, controller: 'authorization_request_forms/build', only: %w[show update], path: 'etapes', as: 'authorization_request_form_build'
      end

      resources :authorization_request_from_templates, only: %i[index create], path: 'templates'
    end

    get 'demandes/:id/reopen-from-external', to: 'external_reopen_authorization_requests#create'

    resources :authorizations, only: %i[show], path: 'habilitations' do
      resources :reopen_authorizations, only: %w[new create], path: 'réouvrir', as: :reopen
    end
  end

  get '/instruction', to: redirect('/instruction/demandes')

  namespace :instruction do
    resources :authorization_requests, only: %w[index show], path: 'demandes' do
      resources :approve_authorization_requests, only: %w[new create], path: 'approuver', as: :approval
      resources :archive_authorization_requests, only: %w[new create], path: 'archiver', as: :archive
      resources :refuse_authorization_requests, only: %w[new create], path: 'refuser', as: :refusal
      resources :request_changes_on_authorization_requests, only: %w[new create], path: 'demande-de-modifications', as: :request_changes
      resources :revoke_authorization_requests, only: %w[new create], path: 'révoquer', as: :revocation

      resources :authorization_request_events, only: :index, path: 'historique', as: :events

      resources :messages, only: %w[index create], path: 'messages'
    end
  end

  namespace :api do
    resources :frontal, only: :index
  end

  mount GoodJob::Engine => '/workers'
end
