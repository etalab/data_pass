class Instruction::EmailsAutomatiquesController < Instruction::AbstractCatalogueController
  before_action :set_formulaire

  def show
    @emails = AutomaticEmailsCatalog.new(@formulaire).build
    @formulaire_demandes_count = @formulaire.authorization_request_class.where(state: :submitted).count
    @formulaire_habilitations_count = Authorization.where(authorization_request_class: @formulaire.authorization_request_class.to_s).where(state: :active).count
  end

  private

  def set_formulaire
    @formulaire = AuthorizationDefinition.find(params.expect(:formulaire_id))
    raise ActiveRecord::RecordNotFound unless @formulaire.provider_slug == @data_provider.slug

    authorize [:instruction, @formulaire], :show?
  rescue StaticApplicationRecord::EntryNotFound
    raise ActiveRecord::RecordNotFound
  end

  def layout_name
    'wide_container'
  end
end
