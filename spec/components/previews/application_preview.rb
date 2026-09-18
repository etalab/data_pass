# Classe de base de toutes les previews Lookbook : elle n’affiche aucun composant, elle donne
# simplement aux previews l’accès aux helpers de vue de l’application (`link_to`, `mail_to`, `tag`,
# les helpers DSFR…) en déléguant les appels inconnus à `ApplicationController.helpers`.
class ApplicationPreview < ViewComponent::Preview
  delegate_missing_to :helpers

  private :method_missing, :respond_to_missing?

  private

  def helpers
    ApplicationController.helpers
  end
end
