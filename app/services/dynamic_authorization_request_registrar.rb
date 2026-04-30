class DynamicAuthorizationRequestRegistrar
  VALID_RUBY_CLASSNAME = /\A[A-Z][a-zA-Z0-9]*\z/

  BLOCK_MODULES = {
    'basic_infos' => AuthorizationExtensions::BasicInfos,
    'legal' => AuthorizationExtensions::CadreJuridique,
    'personal_data' => AuthorizationExtensions::PersonalData,
    'cnous_data_extraction_criteria' => AuthorizationExtensions::CnousDataExtractionCriteria,
  }.freeze

  BLOCK_PROCS = {
    'scopes' => lambda { |klass, _record|
      klass.add_scopes(validation: { presence: true, if: -> { need_complete_validation?(:scopes) } })
    },
    'contacts' => lambda { |klass, record|
      record.contact_types.each do |contact_type|
        klass.contact(contact_type.to_sym, validation_condition: ->(r) { r.need_complete_validation?(:contacts) })
      end
    },
  }.freeze

  def self.call(record)
    new(record).call
  end

  def initialize(record)
    @record = record
  end

  def call
    return Rails.logger.error("DynamicAuthorizationRequestRegistrar: invalid uid '#{@record.uid}', skipping") unless valid_class_name?

    klass = Class.new(AuthorizationRequest)
    @record.blocks.each { |block| apply_block(klass, block) }
    AuthorizationRequest.send(:remove_const, class_name) if AuthorizationRequest.const_defined?(class_name, false)
    AuthorizationRequest.const_set(class_name, klass)
  end

  private

  def apply_block(klass, block)
    block_name = block_name_from(block)

    if BLOCK_MODULES.key?(block_name)
      klass.include(BLOCK_MODULES[block_name])
    elsif BLOCK_PROCS.key?(block_name)
      BLOCK_PROCS[block_name].call(klass, @record)
    else
      log_unknown_block(block_name)
    end
  end

  def block_name_from(block)
    block.is_a?(Hash) ? block['name'] : block
  end

  def log_unknown_block(block_name)
    Sentry.capture_message(
      "DynamicAuthorizationRequestRegistrar: unknown block '#{block_name}' for uid '#{@record.uid}'",
      level: :warning
    )
    Rails.logger.warn("DynamicAuthorizationRequestRegistrar: unknown block '#{block_name}' for uid '#{@record.uid}', skipping")
  end

  def valid_class_name?
    class_name.match?(VALID_RUBY_CLASSNAME)
  end

  def class_name
    @class_name ||= @record.uid.classify
  end
end
