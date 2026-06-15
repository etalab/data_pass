class Molecules::Instruction::DataProviders::CardComponentPreview < ApplicationPreview
  def default
    data_provider = DataProvider.first!
    render Molecules::Instruction::DataProviders::CardComponent.new(data_provider:, definitions_count: 12)
  end
end
