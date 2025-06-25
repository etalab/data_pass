module ImpersonationManagement
  extend ActiveSupport::Concern

  included do
    after_action :track_impersonation_action, if: :impersonating?
  end

  def track_impersonation_action
    return unless %w[create update destroy].include?(action_name)
    return if namespace?(:admin) || namespace?(:api)
    return if controller_name == 'sessions'

    current_impersonation.actions.create!(
      action: action_name,
      controller: controller_name,
      model_type: model_to_track_for_impersonation_type,
      model_id: model_to_track_for_impersonation.id,
    )
  end

  def model_to_track_for_impersonation
    fail NotImplementedError, "Controller #{controller_name} must implement `model_to_track_for_impersonation` method"
  end

  def model_to_track_for_impersonation_type
    if model_to_track_for_impersonation.decorated?
      model_to_track_for_impersonation.object.class.name
    else
      model_to_track_for_impersonation.class.name
    end
  end

  def impersonating?
    cookies[:impersonation_id].present?
  end
end
