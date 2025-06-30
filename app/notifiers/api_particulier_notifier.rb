class APIParticulierNotifier < APIEntreculierNotifier
  def approve(_params)
    notify_france_connect if authorization_request.with_france_connect?

    super
  end
end
