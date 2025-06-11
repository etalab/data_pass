class Admin::ImpersonateController < AdminController
  def new
    @impersonation = Impersonation.new
  end

  def create
    user = find_user_for_impersonation
    return unless user

    return if validate_not_self_impersonation(user)

    impersonation = create_impersonation(user)
    impersonate_user(user)
    log_impersonation_start(impersonation)

    success_message(
      title: 'Impersonation activée',
      description: "Vous êtes maintenant connecté en tant que #{user.email}"
    )
    redirect_to dashboard_path
  end

  def destroy
    AdminEvent.create!(
      admin: true_user,
      name: 'impersonate_stop',
      entity: current_user
    )

    stop_impersonating_user

    success_message(title: 'Impersonation terminée', description: "Vous êtes de nouveau connecté en tant que #{current_user.email}")
    redirect_to admin_path
  end

  private

  def impersonation_params
    params.expect(impersonation: %i[email reason])
  end

  def find_user_for_impersonation
    user = User.find_by(email: impersonation_params[:email])
    return user if user

    error_message(
      title: 'Utilisateur introuvable',
      description: "Aucun utilisateur avec l'email #{impersonation_params[:email]}"
    )
    redirect_to new_admin_impersonate_path
    nil
  end

  def validate_not_self_impersonation(user)
    return false unless user == current_user

    error_message(
      title: 'Erreur',
      description: 'Vous ne pouvez pas vous impersonner vous-même'
    )
    redirect_to new_admin_impersonate_path
    true
  end

  def create_impersonation(user)
    Impersonation.create!(
      user: user,
      admin: current_user,
      reason: impersonation_params[:reason]
    )
  end

  def log_impersonation_start(impersonation)
    AdminEvent.create!(
      admin: current_user,
      name: 'impersonate_start',
      entity: impersonation
    )
  end
end
