FactoryBot.define do
  factory :admin_event do
    name { 'user_roles_changed' }
    admin { create(:user, :admin) }
    entity { create(:user) }
    before_attributes do
      {
        'roles' => [],
      }
    end

    after_attributes do
      {
        'roles' => ['admin'],
      }
    end
  end
end
