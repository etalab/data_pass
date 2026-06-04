class Instruction::DataProvidersController < InstructionController
  def index
    @data_providers = policy_scope([:instruction, DataProvider]).order(:name)
  end
end
