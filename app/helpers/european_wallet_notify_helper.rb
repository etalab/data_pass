module EuropeanWalletNotifyHelper
  def european_wallet_notify_profiles
    EuropeanWalletSubscriber.offered_profiles(registry_open: european_wallet_registry_open?)
      .index_with { |profile| t("pages.european_wallet.notify.profiles.#{profile}") }
  end

  def european_wallet_notify_texts
    moment = european_wallet_registry_open? ? 'after_opening' : 'before_opening'

    %i[title text submit_title].index_with do |key|
      t("pages.european_wallet.notify.#{moment}.#{key}")
    end
  end
end
