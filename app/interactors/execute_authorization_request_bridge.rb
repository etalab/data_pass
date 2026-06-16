class ExecuteAuthorizationRequestBridge < ApplicationInteractor
  BLOCK_BRIDGES = {
    'cnous_data_extraction_criteria' => HubEEProactiviteBridge,
  }.freeze

  def call
    bridge = conventional_bridge || block_bridge
    return if bridge.nil?

    bridge.perform_later(context.authorization_request, context.state_machine_event)
  end

  private

  def conventional_bridge
    Kernel.const_get(:"#{authorization_request_class}Bridge")
  rescue NameError
    nil
  end

  def block_bridge
    BLOCK_BRIDGES[block_name_with_bridge]
  end

  def block_name_with_bridge
    (definition_block_names & BLOCK_BRIDGES.keys).first
  end

  def definition_block_names
    context.authorization_request.definition.blocks.filter_map do |block|
      block.is_a?(Hash) ? (block[:name] || block['name']) : block
    end
  end

  def authorization_request_class
    context.authorization_request.class_name.split('::').last
  end
end
