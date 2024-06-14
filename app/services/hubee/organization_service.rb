class HubEE::OrganizationService

  def initialize(api_host, access_token, siret, code_commune, etablissement, administrateur_metier_data)
    @api_host = api_host
    @access_token = access_token
    @siret = siret
    @code_commune = code_commune
    @etablissement = etablissement
    @administrateur_metier_data = administrateur_metier_data
  end

  def retrieve_or_create_organization
    begin
      faraday_connection.new.get do |req|
        req.url "#{@api_host}/referential/v1/organizations/SI-#{@siret}-#{@code_commune}"
        req.headers['Authorization'] = "Bearer #{@access_token}"
        req.headers['tag'] = 'Portail HubEE'
      end
    rescue Faraday::ResourceNotFound => e
      # 2.2 if organization does not exist, create the organization
      if e.response_status == 404
        Faraday.new.post do |req|
          req.url "#{@api_host}/referential/v1/organizations"
          req.headers['Authorization'] = "Bearer #{@access_token}"
          req.headers['tag'] = 'Portail HubEE'
          req.body = organization_body
        end
      else
        raise
      end
    end
  end

  private

  def organization_body
    {
      type: 'SI',
      companyRegister: @siret,
      branchCode: @code_commune,
      name: @etablissement[:denomination],
      code: @etablissement[:sigle],
      country: 'France',
      postalCode: @etablissement[:code_postal],
      territory: @etablissement[:libelle_commune],
      email: @administrateur_metier_data[:email],
      phoneNumber: @administrateur_metier_data[:phone_number].delete(' ').delete('.').delete('-'),
      status: 'Actif'
    }
  end

  def faraday_connection
    @faraday_connection ||= Faraday.new do |conn|
      conn.request :json
      conn.request :retry, max: 5
      conn.response :raise_error
      conn.response :json, content_type: /\bjson$/
      conn.options.timeout = 2
      conn.adapter Faraday.default_adapter
    end
  end
end
