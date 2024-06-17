class HubEE::OrganizationService

  def initialize(api_host, access_token, siret, etablissement_response, administrateur_metier_data)
    @api_host = api_host
    @access_token = access_token
    @siret = siret
    @etablissement_response = etablissement_response
    @administrateur_metier_data = administrateur_metier_data
  end

  def retrieve_or_create_organization
    begin
      faraday_connection.get do |req|
        req.url "#{@api_host}/referential/v1/organizations/SI-#{@siret}-#{@etablissement_response[:code_commune]}"
        req.headers['Authorization'] = "Bearer #{@access_token}"
        req.headers['tag'] = 'Portail HubEE'
      end
    rescue Faraday::ResourceNotFound => e
      # 2.2 if organization does not exist, create the organization
      if e.response_status == 404
        faraday_connection.post do |req|
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
      branchCode: @etablissement_response[:code_commune],
      name: @etablissement_response[:denomination],
      code: @etablissement_response[:sigle],
      country: 'France',
      postalCode: @etablissement_response[:code_postal],
      territory: @etablissement_response[:libelle_commune],
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
