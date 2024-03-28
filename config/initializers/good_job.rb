ActiveSupport.on_load(:good_job_application_controller) do
  include Authentication

  allow_unauthenticated_access

  before_action do
    raise ActionController::RoutingError.new('Not Found') unless current_user&.admin?
  end
end
