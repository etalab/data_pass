class DynamicAuthorizationRequestRegistrar
  BLOCK_HANDLERS = {
    'basic_infos' => ->(klass, _record) { klass.include(AuthorizationExtensions::BasicInfos) },
    'legal' => ->(klass, _record) { klass.include(AuthorizationExtensions::CadreJuridique) },
    'personal_data' => ->(klass, _record) { klass.include(AuthorizationExtensions::PersonalData) },
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
    if BLOCK_HANDLERS.key?(block)
      BLOCK_HANDLERS[block].call(klass, @record)
    else
      Rails.logger.warn("DynamicAuthorizationRequestRegistrar: unknown block '#{block}' for uid '#{@record.uid}', skipping")
    end
  end

  def valid_class_name?
    class_name.match?(/\A[A-Z][a-zA-Z0-9]*\z/)
  end

  def class_name
    @class_name ||= @record.uid.classify
  end
end
