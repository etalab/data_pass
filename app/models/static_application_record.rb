class StaticApplicationRecord
  include ActiveModel::Model
  include Draper::Decoratable
  include ActiveModel::Serialization

  class EntryNotFound < StandardError; end

  def self.inherited(base)
    base.extend ClassMethods

    base.class_eval do
      private_class_method :values_includes_entry_attribute?
    end
  end

  module ClassMethods
    def all
      @all ||= backend
    end

    def backend
      fail NotImplementedError
    end

    def unscoped
      yield
    end

    def where(conditions = {})
      return all if conditions.blank?

      all.select do |entry|
        conditions.all? do |attr, values|
          values_includes_entry_attribute?(entry, attr, values)
        end
      end
    end

    def exists?(conditions = {})
      where(conditions).any?
    end

    def find(id)
      all.find { |entry| entry.id == id } || fail(EntryNotFound, "Couldn't find #{name} with 'id'=#{id} within static entries")
    end

    def find_by(params)
      where(params).first
    end

    def values_includes_entry_attribute?(entry, attr, values)
      entry_attribute_value = entry.public_send(attr)
      array_values = Array.wrap(values)

      if attr == :authorization_request_class
        entry_attribute_value = entry_attribute_value.to_s
        array_values = array_values.map(&:to_s)
      end

      array_values.include?(entry_attribute_value)
    end
  end

  def id
    fail NotImplementedError
  end

  def [](attr)
    public_send(attr)
  end

  def ==(other)
    id == other.id
  end

  private

  def value_or_default(value, default)
    value.nil? ? default : value
  end
end
