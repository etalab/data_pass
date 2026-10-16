Rails.application.config.to_prepare do
  Doorkeeper::Application.include(RevokesAPIAccessOnDestroy)
end
