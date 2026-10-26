module APIConsents
  extend ActiveSupport::Concern

  private

  def consent_given?(consent)
    ActiveModel::Type::Boolean.new.cast(context.consentement[consent]) == true
  end
end
