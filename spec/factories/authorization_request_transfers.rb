FactoryBot.define do
  factory :authorization_request_transfer do
    authorization_request

    transient do
      entity { :user }
    end

    after(:build) do |authorization_request_transfer, evaluator|
      case evaluator.entity
      when :user
        authorization_request_transfer.from ||= create(:user)
        authorization_request_transfer.to ||= begin
          to_user = create(:user)
          to_user.add_to_organization(authorization_request_transfer.from.current_organization)
          to_user
        end
      when :organization
        authorization_request_transfer.from ||= create(:organization)
        authorization_request_transfer.to ||= create(:organization)
      else
        raise ArgumentError, "Unknown entity: #{evaluator.entity}"
      end
    end
  end
end
