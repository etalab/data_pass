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
    return unless %w[POST PUT PATCH DELETE].include?(request.method)
    return if request.path.start_with?('/admin/impersonate')

    impersonation = current_impersonation
    return unless impersonation

    action = case request.method
             when 'POST' then 'create'
             when 'PUT', 'PATCH' then 'update'
             when 'DELETE' then 'destroy'
             end

    model_info = extract_model_info_from_request

    if model_info[:model_type] && model_info[:model_id]
      ImpersonationAction.create!(
        impersonation: impersonation,
        action: action,
        model_type: model_info[:model_type],
        model_id: model_info[:model_id]
      )
    end
  rescue StandardError => e
    Rails.logger.error "Failed to track impersonation action: #{e.message}"
  end

  def extract_model_info_from_request
    controller_parts = controller_name.singularize.camelize
    
    model_type = controller_parts
    model_id = params[:id]

    if controller_parts.include?('::')
      namespace, model = controller_parts.split('::', 2)
      model_type = model
    end

    { model_type: model_type, model_id: model_id }
  end

  def current_impersonation
    return unless impersonating?
    
    @current_impersonation ||= Impersonation.where(
      user: current_user,
      admin: true_user
    ).where('created_at > ?', 24.hours.ago).last
  end

  def impersonating?
    respond_to?(:true_user) && respond_to?(:current_user) && true_user && current_user && true_user != current_user
  end
end
