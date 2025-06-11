class ApplicationController < ActionController::Base
  layout :custom_layout

  default_form_builder DSFRFormBuilder

  helper ActiveLinks

  before_action :track_impersonation_action, if: :impersonating?

  helper_method :namespace?, :displayed_on_a_public_page?

  def current_namespace
    self.class.name.split('::').first
  end

  def namespace?(namespace)
    current_namespace.underscore == namespace.to_s
  end

  def displayed_on_a_public_page?
    false
  end

  def error_message_for(object, title:, id: nil)
    flash_message(:error, title:, description: object.errors.full_messages, id:, activemodel: true)
  end

  def error_message(title:, description: nil, id: nil, activemodel: false)
    flash_message(:error, title:, description:, id:, activemodel:)
  end

  def success_message(title:, description: nil, id: nil)
    flash_message(:success, title:, description:, id:)
  end

  def info_message(title:, description: nil, id: nil)
    flash_message(:info, title:, description:, id:)
  end

  def warning_message(title:, description: nil, id: nil)
    flash_message(:warning, title:, description:, id:)
  end

  def layout_name
    'container'
  end

  def turbo_request?
    request.headers['HTTP_X_TURBO_REQUEST_ID'].present?
  end

  private

  def flash_message(kind, title:, description:, id:, activemodel: false)
    flash_object = kind == :error ? flash.now : flash

    flash_object[kind] ||= {}
    flash_object[kind]['title'] = title
    flash_object[kind]['description'] = description
    flash_object[kind]['id'] = id
    flash_object[kind]['activemodel'] = activemodel
  end

  def custom_layout
    return 'turbo_rails/frame' if turbo_frame_request?

    layout_name
  end

  def track_impersonation_action
    return unless should_track_impersonation_action?

    impersonation = current_impersonation
    return unless impersonation

    return handle_finished_impersonation if impersonation.finished_at.present?

    create_impersonation_action_record(impersonation)
  rescue StandardError => e
    Rails.logger.error "Failed to track impersonation action: #{e.message}"
  end

  def stop_invalid_impersonation
    session.delete(:impersonated_user_id)
    session.delete(:impersonation_id)

    error_message(
      title: I18n.t('admin.impersonate.errors.title'),
      description: I18n.t('admin.impersonate.errors.session_expired')
    )
    redirect_to dashboard_path
  end

  def model_to_track
    raise NotImplementedError, 'Controllers that need impersonation tracking must implement #model_to_track'
  end

  def should_track_impersonation_action?
    %w[POST PUT PATCH DELETE].include?(request.method) &&
      !request.path.start_with?('/admin/impersonate')
  end

  def handle_finished_impersonation
    stop_invalid_impersonation
  end

  def create_impersonation_action_record(impersonation)
    action = determine_action_from_method
    model = model_to_track
    return unless model

    ImpersonationAction.create!(
      impersonation: impersonation,
      action: action,
      model_type: model.class.name,
      model_id: model.id,
      controller: self.class.name
    )
  end

  def determine_action_from_method
    case request.method
    when 'POST' then 'create'
    when 'PUT', 'PATCH' then 'update'
    when 'DELETE' then 'destroy'
    end
  end
end
