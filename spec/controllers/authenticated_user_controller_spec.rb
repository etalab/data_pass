# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticatedUserController do
  controller(AuthenticatedUserController) do
    def show
      render plain: 'ok'
    end
  end

  let(:user) { create(:user) }

  before do
    routes.draw { get 'show' => 'authenticated_user#show' }

    sign_in(user)
  end

  it 'refresh current organization INSEE payload through job' do
    expect(UpdateOrganizationINSEEPayloadJob).to receive(:perform_later).with(user.current_organization.id)

    get :show
  end
end
