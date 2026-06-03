class Instruction::FormulairesController < Instruction::AbstractCatalogueController
  def index
    @formulaires = @data_provider.authorization_definitions
      .select { |definition| permitted_definition?(definition) }
  end

  def show
    @formulaire = AuthorizationDefinition.find(params.expect(:id))
    raise ActiveRecord::RecordNotFound unless @formulaire.provider_slug == @data_provider.slug

    authorize [:instruction, @formulaire], :show?

    @cas_usages = @formulaire.available_forms
    @demandes_counts = counts_by_form_uid(AuthorizationRequest)
    @habilitations_counts = counts_by_form_uid(Authorization)
  rescue StaticApplicationRecord::EntryNotFound
    raise ActiveRecord::RecordNotFound
  end

  private

  def permitted_definition?(definition)
    Instruction::AuthorizationDefinitionPolicy.new(pundit_user, definition).show?
  end

  def counts_by_form_uid(model)
    model.where(form_uid: @cas_usages.map(&:uid)).group(:form_uid).count
  end
end
