class Molecules::Instruction::DataProviders::CardComponent < ApplicationComponent
  def initialize(data_provider:, definitions_count:)
    @data_provider = data_provider
    @definitions_count = definitions_count
  end

  private

  attr_reader :data_provider, :definitions_count

  delegate :name, :slug, :logo, to: :data_provider
end
