class ApplicationController < ActionController::Base
  include Pundit::Authorization

  helper ActiveLinks

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized
    redirect_to root_path, alert: { title: t('.title') }
  end

  def error_message_for(object, title:, id: nil)
    flash_message(:error, title:, description: object.errors.full_messages, id:, activemodel: true)
  end

  def error_message(title:, description: nil, id: nil)
    flash_message(:error, title:, description:, id:)
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

  private

  def flash_message(kind, title:, description:, id:, activemodel: false)
    flash_object = kind == :error ? flash.now : flash

    flash_object[kind] ||= {}
    flash_object[kind]['title'] = title
    flash_object[kind]['description'] = description
    flash_object[kind]['id'] = id
    flash_object[kind]['activemodel'] = activemodel
  end
end
