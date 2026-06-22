class Instruction::DataProvidersController < InstructionController
  def index
    authorize %i[instruction data_provider], :index?
    @data_providers = policy_scope([:instruction, DataProvider]).with_attached_logo.order(:name)
    @definitions_counts = @data_providers.index_with { |data_provider| reporter_definitions_count(data_provider) }
  end

  private

  def reporter_definitions_count(data_provider)
    data_provider.authorization_definitions.count { |ad| current_user.reporter?(ad.id) }
  end
end
