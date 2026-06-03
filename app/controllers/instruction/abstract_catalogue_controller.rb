class Instruction::AbstractCatalogueController < InstructionController
  before_action :set_data_provider

  private

  def set_data_provider
    @data_provider = DataProvider.friendly.find(params.expect(:provider_slug))
    authorize [:instruction, @data_provider], :show?
  end
end
