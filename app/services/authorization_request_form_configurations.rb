class AuthorizationRequestFormConfigurations
  include Singleton

  def all
    config
  end

  private

  def config
    @config ||= YAML.load(config_interpolated, aliases: true)
  end

  def config_interpolated
    ERB.new(config_raw).result
  end

  def config_raw
    data_providers_files.inject('') do |final_payload, file|
      final_payload << "#{File.read(file)}\n"
    end
  end

  def data_providers_files
    Dir[Rails.root.join('config/authorization_request_forms/*.y*ml').to_s]
  end
end
