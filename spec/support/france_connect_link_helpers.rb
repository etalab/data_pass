module FranceConnectLinkHelpers
  def link_fc_authorization_to_request(authorization_request, fc_authorization)
    merged_data = authorization_request.data.merge(
      'france_connect_authorization_id' => fc_authorization.id.to_s
    )
    authorization_request.update_column(:data, merged_data) # rubocop:disable Rails/SkipsModelValidations
    authorization_request.latest_authorization.update_column(:data, merged_data) # rubocop:disable Rails/SkipsModelValidations
  end
end
