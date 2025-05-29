module ProConnectPayloads
  def info_payload
    context.pro_connect_omniauth_payload['info'] || {}
  end

  def raw_info_payload
    context.pro_connect_omniauth_payload.dig('extra', 'raw_info') || {}
  end
end
