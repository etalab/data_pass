class Instruction::CasUsagesController < Instruction::AbstractCatalogueController
  before_action :set_formulaire

  def show
    @cas_usage = @formulaire.available_forms.find { |form| form.uid == params[:uid] }
    raise ActiveRecord::RecordNotFound unless @cas_usage

    authorize [:instruction, @cas_usage], :show?
  end

  private

  def set_formulaire
    @formulaire = AuthorizationDefinition.find(params.expect(:formulaire_id))
    raise ActiveRecord::RecordNotFound unless @formulaire.provider_slug == @data_provider.slug

    authorize [:instruction, @formulaire], :show?
  rescue StaticApplicationRecord::EntryNotFound
    raise ActiveRecord::RecordNotFound
  end
end
