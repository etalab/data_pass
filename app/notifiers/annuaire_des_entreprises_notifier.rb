class AnnuaireDesEntreprisesNotifier < BaseNotifier
  def approve(_params)
    webhook_notification('approve')

    super
  end
end
