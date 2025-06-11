module ImpersonationManagement
  extend ActiveSupport::Concern

  included do
    before_action :track_impersonation_action, if: :impersonating?
  end

  def track_impersonation_action
    return unless %w[create update destroy].include?(action_name)
    return if controller_name == 'impersonate'

    current_impersonation.actions.create!(
      action: action_name,
      controller: controller_name,
      model_type: model_to_track.class.name,
      model_id: model_to_track.id,
    )
  end

  def model_to_track
    fail NotImplementedError, "Controller #{controller_name} must implement `model_to_track` method"
  end

  def impersonating?
    cookies[:impersonation_id].present?
  end

  def current_impersonation
    @current_impersonation ||= Impersonation.find_by(id: cookies[:impersonation_id])
  end
end
