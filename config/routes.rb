Rails.application.routes.draw do
  root 'pages#home'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')

  get 'local-sign-in', to: 'authenticated_user#bypass_login' if Rails.env.development?

  get 'compte/deconnexion', to: 'sessions#destroy', as: :signout

  get '/tableau-de-bord', to: 'dashboard#index', as: :dashboard
  get '/tableau-de-bord/:id', to: 'dashboard#show', as: :dashboard_show

  get '/compte', to: 'profile#edit', as: :profile
  patch '/compte', to: 'profile#update'

  patch '/settings/notifications', to: 'notifications_settings#update', as: :notifications_settings

  get '/public/demandes/:id', to: 'public/authorization_requests#show', as: :public_authorization_request

  get '/demandes-instructeurs/:id/finaliser', to: 'claim_instructor_draft_requests#show', as: :claim_instructor_draft_request
  post '/demandes-instructeurs/:id/finaliser', to: 'claim_instructor_draft_requests#create'

  get '/stats', to: 'stats#index'

  scope(path_names: { new: 'nouveau', edit: 'modifier' }) do

    namespace :user, path: 'usager' do
      resources :organizations, only: %i[index create], path: 'organisations' do
        member do
          get 'courant', action: :set_as_current, as: :set_as_current
        end
      end
    end

    resources :organizations, only: %i[new create show], path: 'organisations', param: :siret

    resources :authorization_requests, only: %w[show], path: 'demandes' do
      resources :messages, only: %w[index create], path: 'messages'
      resources :archive_authorization_requests, only: %w[new create], path: 'archiver', as: :archive
      resources :transfer_authorization_requests, only: %w[new create], path: 'transferer', as: :transfer
      resources :manual_transfer_authorization_requests, only: %w[new], path: 'demande-de-transfert', as: :manual_transfer
      resources :blocks, only: %w[edit update], path: 'blocs', controller: 'authorization_requests/blocks'
      resources :cancel_authorization_reopenings, only: %w[new create], path: 'annuler_reouverture', as: :cancel_reopening

      resources :authorizations, only: :show, path: 'habilitations'
    end

    resources :authorizations, only: :show, path: 'habilitations'

    resources :authorization_definitions, path: 'demandes', only: :index

    scope 'demandes/:authorization_definition_id', module: :authorization_definitions do
      resources :forms, only: %w[index], path: 'formulaires', as: :authorization_definition_forms
    end

    get '/demandes/:definition_id/nouveau', to: 'authorization_requests#new', as: :new_authorization_request
    get '/demandes/:definition/processing_time', to: 'authorization_request_stats#processing_time', as: :processing_time

    get '/demandes/:authorization_request_id/prochaine-etape', to: 'next_authorization_request_stage#new', as: :next_authorization_request_stage
    post '/demandes/:authorization_request_id/prochaine-etape', to: 'next_authorization_request_stage#create'

    get '/demandes/:authorization_request_id/annuler-prochaine-etape', to: 'cancel_next_authorization_request_stage#new', as: :cancel_next_authorization_request_stage
    post '/demandes/:authorization_request_id/annuler-prochaine-etape', to: 'cancel_next_authorization_request_stage#create'

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

    get 'faq', to: 'pages#faq', as: :faq
    get 'accessibilite', to: 'pages#accessibilite', as: :accessibilite

    get 'cgu_api_impot_particulier_bas', to: 'pages#cgu_api_impot_particulier_bas', as: :cgu_api_impot_particulier_bas
    get 'cgu_api_impot_particulier_prod', to: 'pages#cgu_api_impot_particulier_prod', as: :cgu_api_impot_particulier_prod

    get 'demandes/:id/reopen-from-external', to: 'external_reopen_authorization_requests#create'

    get 'redirect-from-v1/:id', to: 'redirect_from_v1#show', as: :redirect_from_v1

    resources :authorization_requests, only: [] do
      resources :authorizations, only: [] do
        resources :reopen_authorizations, only: %w[new create]
      end
    end
  end

  get '/instruction', to: redirect('/instruction/tableau-de-bord/demandes')
  get '/instruction/demandes', to: redirect('/instruction/tableau-de-bord/demandes')

  namespace :instruction do
    get '/tableau-de-bord/:id', to: 'dashboard#show', as: :dashboard_show
    resources :authorization_requests, only: %w[show], path: 'demandes' do
      resources :approve_authorization_requests, only: %w[new create], path: 'approuver', as: :approval
      resources :archive_authorization_requests, only: %w[new create], path: 'archiver', as: :archive
      resources :refuse_authorization_requests, only: %w[new create], path: 'refuser', as: :refusal
      resources :request_changes_on_authorization_requests, only: %w[new create], path: 'demande-de-modifications', as: :request_changes
      resources :revoke_authorization_requests, only: %w[new create], path: 'révoquer', as: :revocation
      resources :cancel_authorization_reopenings, only: %w[new create], path: 'annuler_reouverture', as: :cancel_reopening
      resources :transfer_authorization_requests, only: %w[new create], path: 'transferer', as: :transfer

      resources :authorization_request_events, only: :index, path: 'historique', as: :events
      resources :authorizations, only: :index, path: 'habilitations'
      resources :france_connected_authorizations, only: :index, path: 'habilitations-france-connectees'

      resources :messages, only: %w[index create], path: 'messages'
    end

    resources :instructor_draft_requests, path: 'instructeurs-demandes', except: :show do
      collection do
        get :start, path: 'commencer'
      end

      resources :invite, only: [:new, :create], controller: 'instructor_draft_requests/invite'
    end
  end

  get '/admin', to: 'admin#index', as: :admin

  namespace :admin do
    resources :whitelisted_verified_emails, only: %w[index new create], path: 'emails-verifies'
    resources :users_with_roles, only: %i[index new create edit update], path: 'utilisateurs-avec-roles'
    resource :impersonate, only: %i[new create destroy], controller: 'impersonate'
    resource :transfer_authorization_request, only: %i[new create], path: 'transferer-demande'
  end

  %w[/api/oauth /api/v1/oauth].each do |path|
    use_doorkeeper scope: path do
      skip_controllers :applications, :authorized_applications
    end
  end

  get '/api-docs/v1.yaml', to: ->(_env) { [200, { 'Content-Type' => 'application/yaml', 'Content-Disposition' => 'inline;filename="datapass-v1.yaml"' }, [File.read(Rails.root.join('config/openapi/v1.yaml'))]] }, as: :open_api_v1

  get '/developpeurs', to: 'developers#index', as: :developers_root

  namespace :developers, path: 'developpeurs' do
    resources :oauth_applications, only: :index, path: 'applications'
    get 'documentation', to: 'open_api#show'
  end

  namespace :api do
    resources :frontal, only: :index

    namespace :v1 do
      get '/me', to: 'credentials#me'

      resources :authorization_requests, path: 'demandes', only: %i[index show] do
        resources :authorization_request_events, only: [:index], path: 'events', as: :events
      end

      resources :authorizations, path: 'habilitations', only: %i[index show]

      resources :authorization_definitions, path: 'definitions', only: %i[index show]

      resources :authorization_request_forms, path: 'definitions/:id/formulaires', only: %i[index]
    end
  end

  get '/dgfip/export', to: 'dgfip/export#show', as: :dgfip_export

  if Rails.env.local?
    post '/dummy/valid/webhooks', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, [{token_id: SecureRandom.hex(16)}.to_json]] }
    post '/dummy/invalid/webhooks', to: ->(_env) { [422, { 'Content-Type' => 'application/json' }, [{hello: 'world'}.to_json]] }
  end

  mount GoodJob::Engine => '/workers'
end
