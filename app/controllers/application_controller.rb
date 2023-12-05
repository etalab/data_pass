class ApplicationController < ActionController::Base
  helper ActiveLinks

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

  private

  def flash_message(kind, title:, description:, id:, activemodel: false)
    flash[kind] ||= {}
    flash[kind]['title'] = title
    flash[kind]['description'] = description
    flash[kind]['id'] = id
    flash[kind]['activemodel'] = activemodel
  end
end
