class Instruction::CasUsagesController < Instruction::AbstractCatalogueController
  before_action :set_formulaire

  def show
    @cas_usage = @formulaire.available_forms.find { |form| form.uid == params[:uid] }
    raise ActiveRecord::RecordNotFound unless @cas_usage

    authorize [:instruction, @cas_usage], :show?

    @authorization_request = @cas_usage.authorization_request_class.new(form_uid: @cas_usage.uid).tap do |ar|
      ar.assign_attributes(@cas_usage.initialize_with)
    end.decorate
  end

  private

  def layout_name
    'wide_container'
  end

  def set_formulaire
    @formulaire = AuthorizationDefinition.find(params.expect(:formulaire_id))
    raise ActiveRecord::RecordNotFound unless @formulaire.provider_slug == @data_provider.slug

    authorize [:instruction, @formulaire], :show?
  rescue StaticApplicationRecord::EntryNotFound
    raise ActiveRecord::RecordNotFound
  end
end
