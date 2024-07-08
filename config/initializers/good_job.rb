Rails.application.configure do
  config.good_job.enable_cron = true
  config.good_job.cron = Rails.application.config_for(:schedule)
  config.good_job.dashboard_default_locale = :fr
end

ActiveSupport.on_load(:good_job_application_controller) do
  include Authentication

  allow_unauthenticated_access

  before_action do
    raise ActionController::RoutingError.new('Not Found') unless current_user&.admin?
  end
end
