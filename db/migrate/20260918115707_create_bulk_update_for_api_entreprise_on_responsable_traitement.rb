class CreateBulkUpdateForAPIEntrepriseOnResponsableTraitement < ActiveRecord::Migration[8.1]
  PRODUCTION_AUTHOR_ID = 43_809

  def up
    return if author.nil?

    bulk_update = BulkAuthorizationRequestUpdate.create!(
      authorization_definition_uid: 'api_entreprise',
      application_date: Date.current,
      reason:,
    )

    AuthorizationRequestEvent.create!(
      name: 'bulk_update',
      entity: bulk_update,
      user: author,
    )
  end

  def down; end

  private

  def author
    @author ||= if Rails.env.production?
                  User.find(PRODUCTION_AUTHOR_ID)
                else
                  User.first
                end
  end

  def reason
    <<~REASON
      Le responsable de traitement n’est dorénavant plus nécessaire pour l’obtention d’une habilitation à API Entreprise. Les informations déjà renseignées sont conservées mais ne sont plus affichées ni utilisées.

      Le contact métier de votre habilitation reste le référent pour les questions relatives aux aspects métiers de votre service exploitant API Entreprise.

      Ces changements sont effectifs à partir du %{humanized_application_date}.
    REASON
  end
end
