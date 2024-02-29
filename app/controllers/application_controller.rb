class ApplicationController < ActionController::Base
  layout :custom_layout

  default_form_builder DSFRFormBuilder

  helper ActiveLinks

  helper_method :namespace?

  def current_namespace
    self.class.name.split('::').first
  end

  def namespace?(namespace)
    current_namespace.underscore == namespace.to_s
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
end
