module ProConnectPayloads
  def raw_info_payload
    context.pro_connect_omniauth_payload.dig('extra', 'raw_info') || {}
  end
end
