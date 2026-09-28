class APIParticulierNotifier < APIEntreculierNotifier
  def approve(params)
    notify_france_connect if authorization_request.with_france_connect?
    notify_hubee_formulaire_qf(params)

    super
  end
end
