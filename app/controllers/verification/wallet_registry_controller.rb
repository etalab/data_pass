class Verification::WalletRegistryController < AuthenticatedUserController
  def show
    authorize %i[verification wallet_registry]
  end
end
