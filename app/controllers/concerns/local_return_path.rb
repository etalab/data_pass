module LocalReturnPath
  extend ActiveSupport::Concern

  private

  def local_return_path(path)
    return unless local_path?(path)

    uri = URI.parse(path)
    [uri.path, uri.query].compact.join('?')
  end

  def local_path?(path)
    path.is_a?(String) && path.start_with?('/') && !path.start_with?('//') && path.exclude?('\\') && URI.parse(path).host.nil?
  rescue URI::InvalidURIError
    false
  end
end
