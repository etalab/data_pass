class Instruction::RevokeOauthApplicationsIfNoDeveloperRole
  include Interactor

  def call
    return if context.user.developer?

    Doorkeeper::Application.where(owner: context.user).destroy_all
  end
end
