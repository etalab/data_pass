module MonCompteProPayloads
  def info_payload
    payload['info'].to_h
  end

  def payload
    @payload ||= context.mon_compte_pro_omniauth_payload
  end
end
