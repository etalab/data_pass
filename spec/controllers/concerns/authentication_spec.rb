# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Authentication do
  controller(ApplicationController) do
    include Authentication
    impersonates :user

    def show
      impersonating?

      render plain: 'ok'
    end
  end

  let(:user) { create(:user, :admin) }
  let(:another_user) { create(:user) }

  before do
    routes.draw { get 'show' => 'anonymous#show' }

    session[:user_id] = {
      'value' => user.id,
      'expires_at' => 1.month.from_now
    }

    session[:impersonated_user_id] = another_user.id
  end

  describe '#impersonating?' do
    context 'when impersonation cookie is not present' do
      it 'returns false and stops impersonation' do
        get :show

        expect(controller.impersonating?).to be false

        expect(session[:impersonated_user_id]).to be_nil

        get :show

        expect(controller.true_user).to eq(user)
        expect(controller.current_user).to eq(user)
      end
    end

    context 'when impersonation cookie is present' do
      before do
        request.cookies[:impersonation_id] = create(:impersonation).id
      end

      it 'returns true and current impersonation exists' do
        get :show

        expect(controller.impersonating?).to be true

        expect(controller.current_user).to eq(another_user)
        expect(controller.true_user).to eq(user)
      end
    end
  end
end
