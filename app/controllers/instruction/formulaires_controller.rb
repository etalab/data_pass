class Instruction::FormulairesController < Instruction::AbstractCatalogueController
  def index
    @formulaires = @data_provider.authorization_definitions
      .select { |definition| permitted_definition?(definition) }

    classes = @formulaires.map(&:authorization_request_class).map(&:to_s)
    @demandes_counts = AuthorizationRequest.where(state: :submitted).where(type: classes).group(:type).count
    @habilitations_counts = Authorization.where(state: :active).where(authorization_request_class: classes).group(:authorization_request_class).count
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

    @cas_usages_count = @formulaire.available_forms.
    @demandes_count = @formulaire.authorization_request_class.where(state: :submitted).count
    @habilitations_counts = Authorization.where(authorization_request_class: @formulaire.authorization_request_class.to_s).where(state: :active).count
  rescue StaticApplicationRecord::EntryNotFound
    raise ActiveRecord::RecordNotFound
  end

  private

  def layout_name
    'wide_container'
  end

  def counts_by_definition(model)
    
    model.where(type: classes).group(:type).count
  end

  def permitted_definition?(definition)
    Instruction::AuthorizationDefinitionPolicy.new(pundit_user, definition).show?
  end
end
