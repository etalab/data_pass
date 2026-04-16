class ApplicationController < ActionController::Base
  class BannedUserError < StandardError; end

  layout :custom_layout

  default_form_builder DsfrFormBuilder

  helper ActiveLinks

  helper_method :namespace?, :displayed_on_a_public_page?, :impersonating?

  rescue_from BannedUserError, with: :reject_banned_user

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
    flash_message(:error, title:, errors: object.errors.full_messages, id:)
  end

  def error_message(title:, description: nil, errors: nil, id: nil, tiny: false)
    flash_message(:error, title:, description:, errors:, id:, tiny:)
  end

  def success_message(title:, description: nil, id: nil, tiny: false)
    flash_message(:success, title:, description:, id:, tiny:)
  end

  def info_message(title:, description: nil, id: nil, tiny: false)
    flash_message(:info, title:, description:, id:, tiny:)
  end

  def warning_message(title:, description: nil, id: nil, tiny: false)
    flash_message(:warning, title:, description:, id:, tiny:)
  end

  def layout_name
    'container'
  end

  def turbo_request?
    request.headers['HTTP_X_TURBO_REQUEST_ID'].present?
  end

  def impersonating?
    false
  end

  private

  def reject_banned_user
    sign_out if user_signed_in?
    flash[:error] = { 'title' => I18n.t('sessions.authenticate_user.errors.banned') }
    redirect_to root_path
  end

  def flash_message(kind, **options)
    flash_object = flash_object_for(kind)
    flash_object[kind] = options.transform_keys(&:to_s)
  end

  def flash_object_for(kind)
    kind == :error ? flash.now : flash
  end

  def custom_layout
    return 'turbo_rails/frame' if turbo_frame_request?

    layout_name
  end
end
