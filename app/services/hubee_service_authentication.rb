class HubEEServiceAuthentication
  def initialize(client_id, client_secret, hubee_auth_url)
    @client_id = client_id
    @client_secret = client_secret
    @hubee_auth_url = hubee_auth_url
  end

  def retrieve_body
    Faraday.new.post do |req|
      req.url @hubee_auth_url
      req.headers['Authorization'] = "Basic #{Base64.strict_encode64("#{@client_id}:#{@client_secret}")}"
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.headers['tag'] = 'Portail HubEE'
      req.body = URI.encode_www_form({ grant_type: 'client_credentials', scope: 'ADMIN' })
    end
  end
end
