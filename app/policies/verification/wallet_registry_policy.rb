class Verification::WalletRegistryPolicy < ApplicationPolicy
  def show?
    user.verifier?
  end
end
