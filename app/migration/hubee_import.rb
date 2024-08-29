require 'csv'

class HubEEImport
  include Singleton
  include ImportUtils

  def build_csv_from_api(env: 'production', load_local: true)
    @api_env = env

    bodies = {}
    {
      'hubee_cert_dc' => %w[CERTDC],
      'hubee_dila' => %w[
        EtatCivil
        depotDossierPACS
        recensementCitoyen
        HebergementTourisme
        JeChangeDeCoordonnees
      ]
    }.each do |kind, codes|
      if load_local && File.exist?(dumps_path("#{kind}.json"))
        body = JSON.parse(File.read(dumps_path("#{kind}.json")))
      else
        body = []

        loop do
          init_body_count = body.size
          max_result = 5000

          result = get_result(codes, offset: body.count, max_result: max_result)
          body = body.concat(JSON.parse(result.body.force_encoding('UTF-8')))

          break if body.count < init_body_count + max_result
        end

        File.write(dumps_path("#{kind}.json"), body.to_json)
      end

      bodies[kind] = body
    end

    CSV.open(dumps_path('hubee_subscriptions.csv'), 'w') do |csv|
      csv << bodies.values[0][0].keys + ['kind']

      bodies.each do |kind, body|
        body.each do |entry|
          csv << entry.values.map(&:to_json) + [kind]
        end
      end
    end
  end

  private

  def data_for(kind)
    @datas ||= {}
    @datas[kind] ||= csv(kind)
    @datas[kind]
  end

  def get_result(codes, offset:, max_result:)
    api_http_connection.get(
      "#{api_url}/referential/v1/subscriptions",
      {
        maxResult: max_result,
        offSet: offset,
        processCode: codes.join(',')
      }
    )
  end

  def api_http_connection
    Faraday.new do |conn|
      conn.request :retry, max: 5
      conn.response :raise_error
      conn.options.timeout = 10
      conn.request :gzip
      conn.request :authorization, 'Bearer', -> { access_token }
    end
  end

  def access_token
    return @access_token if @access_token.present?

    http_connection = Faraday.new do |conn|
      conn.request :retry, max: 5
      conn.response :raise_error
      conn.options.timeout = 5
      conn.response :json
    end

    @access_token ||= http_connection.post(
      auth_url,
      'grant_type=client_credentials&scope=ADMIN',
      {
        'Authorization' => "Basic #{Base64.strict_encode64("#{consumer_key}:#{consumer_secret}")}"
      }
    ).body['access_token']
  end

  def auth_url = config['auth_url']
  def api_url = config['api_url']
  def consumer_key = config['consumer_key']
  def consumer_secret = config['consumer_secret']

  def config
    YAML.load_file(Rails.root.join('app', 'migration', '.hubee_config.yml'))[@api_env]
  end
end
