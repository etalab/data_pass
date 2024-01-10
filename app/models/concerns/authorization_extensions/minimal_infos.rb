module AuthorizationExtensions::MinimalInfos
  extend ActiveSupport::Concern

  included do
    %i[
      intitule
      description
    ].each do |attr|
      add_attribute attr

      validates attr, presence: true, if: -> { need_complete_validation?(:minimal_infos) }
    end
  end
end
