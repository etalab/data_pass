class Setting < ApplicationRecord
  class UnknownKeyError < StandardError; end

  DEFINITIONS = {
    insee_client_id: { type: :string, env: 'INSEE_CLIENT_ID', credential: %i[insee_client_id] },
    insee_client_secret: { type: :string, env: 'INSEE_CLIENT_SECRET', credential: %i[insee_client_secret] },
    insee_username: { type: :string, env: 'INSEE_USERNAME', credential: %i[insee_username] },
    insee_password: { type: :string, env: 'INSEE_PASSWORD', credential: %i[insee_password] },
    insee_calls_enabled: { type: :enabled_unless_false, env: 'INSEE_CALLS_ENABLED', default: true },
  }.freeze

  REDIS_CACHE_KEY = 'setting:cache_version'.freeze

  encrypts :value, deterministic: false

  validates :key, presence: true, uniqueness: true, inclusion: { in: DEFINITIONS.keys.map(&:to_s) }

  after_commit { self.class.invalidate_cache! }

  class << self
    def fetch(key)
      definition = definition_for(key)
      raw = raw_value_for(key, definition)

      return definition[:default] if raw.nil?

      cast(raw, definition[:type])
    end

    def set(key, value)
      definition_for(key)

      find_or_initialize_by(key: key.to_s).update!(value: value.to_s)
      value
    end

    def unset(key)
      definition_for(key)

      find_by(key: key.to_s)&.destroy!
    end

    def overridden_keys
      stored_values.keys
    end

    def definition_for(key)
      DEFINITIONS.fetch(key.to_sym) { raise UnknownKeyError, "Unknown setting '#{key}'" }
    end

    def invalidate_cache!
      @stored_values = nil
      @cache_version = nil
      Kredis.counter(REDIS_CACHE_KEY).increment
    end

    private

    def raw_value_for(key, definition)
      stored_values[key.to_s].presence ||
        environment_value(definition) ||
        credential_value(definition)
    end

    def environment_value(definition)
      return if definition[:env].nil?

      ENV[definition[:env]].presence
    end

    def credential_value(definition)
      return if definition[:credential].nil?

      Rails.application.credentials.dig(*definition[:credential])
    end

    def cast(value, type)
      case type
      when :enabled_unless_false then value.to_s != 'false'
      else value
      end
    end

    def stored_values
      invalidate_if_stale
      @stored_values ||= readable_stored_values
    rescue ActiveRecord::NoDatabaseError
      {}
    rescue ActiveRecord::StatementInvalid => e
      raise unless e.cause.is_a?(PG::UndefinedTable)

      {}
    end

    def readable_stored_values
      all.to_a.filter_map { |setting| readable_entry(setting) }.to_h
    end

    def readable_entry(setting)
      [setting.key, setting.value]
    rescue ActiveRecord::Encryption::Errors::Base => e
      Sentry.capture_exception(e, level: :warning)

      nil
    end

    def invalidate_if_stale
      current_version = redis_cache_version
      return if current_version && @cache_version == current_version

      @stored_values = nil
      @cache_version = current_version
    end

    def redis_cache_version
      counter = Kredis.counter(REDIS_CACHE_KEY)

      counter.failsafe(returning: nil) { counter.value }
    end
  end
end
