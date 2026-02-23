class DynamicAuthorizationRequestRegistrar
  BLOCK_HANDLERS = {
    'basic_infos' => ->(klass, _record) { klass.include(AuthorizationExtensions::BasicInfos) },
    'cadre_juridique' => ->(klass, _record) { klass.include(AuthorizationExtensions::CadreJuridique) },
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

  def self.register(record)
    klass = Class.new(AuthorizationRequest)
    record.blocks.each { |block| BLOCK_HANDLERS[block]&.call(klass, record) }
    AuthorizationRequest.const_set(record.uid.classify, klass)
  end
end
