module LocalReturnPath
  extend ActiveSupport::Concern

  private

  def local_return_path(path)
    return unless local_path?(path)

    uri = URI.parse(path)
    [uri.path, uri.query].compact.join('?')
  rescue URI::InvalidURIError
    nil
  end

  def local_path?(path)
    path.is_a?(String) && path.start_with?('/') && !protocol_relative?(path) && !contains_backslash?(path)
  end

  def protocol_relative?(path)
    path.start_with?('//')
  end

  def contains_backslash?(path)
    path.include?('\\')
  end
end
