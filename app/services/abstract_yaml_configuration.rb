class AbstractYAMLConfiguration
  include Singleton

  def all
    config
  end

  protected

  def files
    fail NotImplementedError
  end

  private

  def config
    @config ||= YAML.load(config_interpolated, aliases: true, symbolize_names: true)
  end

  def config_interpolated
    ERB.new(config_raw).result
  end

  def config_raw
    files.inject('') do |final_payload, file|
      final_payload << "#{File.read(file)}\n"
    end
  end
end
