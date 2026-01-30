class FranceConnectDataBuilder
  attr_reader :authorization_request

  def initialize(authorization_request)
    @authorization_request = authorization_request
  end

  def data
    authorization_request.france_connect_attributes.transform_keys(&:to_s)
  end

  def attach_documents_to(authorization)
    authorization_request.attach_documents_to_france_connect_authorization(authorization)
  end
end
