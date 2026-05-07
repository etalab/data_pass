Before('@cnous_data_extraction_criteria') do
  @__original_block_order = HabilitationType::BLOCK_ORDER
  HabilitationType.send(:remove_const, :BLOCK_ORDER)
  HabilitationType.const_set(
    :BLOCK_ORDER,
    %w[basic_infos legal personal_data scopes cnous_data_extraction_criteria contacts].freeze
  )
end

After('@cnous_data_extraction_criteria') do
  next unless defined?(@__original_block_order) && @__original_block_order

  HabilitationType.send(:remove_const, :BLOCK_ORDER)
  HabilitationType.const_set(:BLOCK_ORDER, @__original_block_order)
  AuthorizationDefinition.reset!
  AuthorizationRequestForm.reset!
end
