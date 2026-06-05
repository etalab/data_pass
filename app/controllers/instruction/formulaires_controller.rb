class Instruction::FormulairesController < Instruction::AbstractCatalogueController
  def index
    @formulaires = @data_provider.authorization_definitions
      .select { |definition| permitted_definition?(definition) }
  end

  def show
    @formulaire = AuthorizationDefinition.find(params.expect(:id))
    raise ActiveRecord::RecordNotFound unless @formulaire.provider_slug == @data_provider.slug

    # on utilise la demande libre pour montrer le formulaire
    @cas_usage = @formulaire.default_form
    @authorization_request = @formulaire.authorization_request_class.new(form_uid: @cas_usage.uid).tap do |ar|
      ar.assign_attributes(@cas_usage.initialize_with)
    end.decorate

    authorize [:instruction, @formulaire], :show?

    @cas_usages = @formulaire.available_forms
    @demandes_counts = counts_by_form_uid(AuthorizationRequest)
    @habilitations_counts = counts_by_form_uid(Authorization)
  rescue StaticApplicationRecord::EntryNotFound
    raise ActiveRecord::RecordNotFound
  end

  private

  def layout_name
    'wide_container'
  end

  def permitted_definition?(definition)
    Instruction::AuthorizationDefinitionPolicy.new(pundit_user, definition).show?
  end

  def counts_by_form_uid(model)
    model.where(form_uid: @cas_usages.map(&:uid)).group(:form_uid).count
  end
end
