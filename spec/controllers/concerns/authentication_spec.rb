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
      'expires_at' => 12.hours.from_now,
      'absolute_expires_at' => 24.hours.from_now
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

  describe '#sign_in' do
    subject(:do_sign_in) do
      controller.sign_in(
        user,
        identity_federator: 'proconnect',
        identity_provider_uid: '1234'
      )
    end

    it 'sets expires_at to approximately 12 hours from now' do
      freeze_time do
        do_sign_in

        expires_at = session[:user_id][:expires_at] || session[:user_id]['expires_at']
        expect(expires_at).to be_within(1.minute).of(12.hours.from_now)
      end
    end

    it 'sets absolute_expires_at to approximately 24 hours from now' do
      freeze_time do
        do_sign_in

        absolute_expires_at = session[:user_id][:absolute_expires_at] || session[:user_id]['absolute_expires_at']
        expect(absolute_expires_at).to be_within(1.minute).of(24.hours.from_now)
      end
    end

    it 'sets identity_federator and identity_provider_uid' do
      do_sign_in

      identity_federator = session[:user_id][:identity_federator] || session[:user_id]['identity_federator']
      identity_provider_uid = session[:user_id][:identity_provider_uid] || session[:user_id]['identity_provider_uid']
      expect(identity_federator).to eq('proconnect')
      expect(identity_provider_uid).to eq('1234')
    end

    context 'when omniauth.pc.* keys are already in the session' do
      before do
        session['omniauth.pc.access_token'] = 'token_access'
        session['omniauth.pc.id_token'] = 'token_id'
        session['omniauth.pc.refresh_token'] = 'token_refresh'
      end

      it 'preserves omniauth.pc.* keys after session rotation' do
        do_sign_in

        expect(session['omniauth.pc.access_token']).to eq('token_access')
        expect(session['omniauth.pc.id_token']).to eq('token_id')
        expect(session['omniauth.pc.refresh_token']).to eq('token_refresh')
      end
    end

    context 'when return_to_after_sign_in is present in the session' do
      before do
        session[:return_to_after_sign_in] = 'http://test.host/demandes/42'
      end

      it 'preserves return_to_after_sign_in after session rotation' do
        do_sign_in

        expect(session[:return_to_after_sign_in]).to eq('http://test.host/demandes/42')
      end
    end
  end

  describe '#valid_user_session?' do
    context 'when idle timeout has expired' do
      before do
        session[:user_id] = {
          'value' => user.id,
          'expires_at' => 1.second.ago,
          'absolute_expires_at' => 24.hours.from_now
        }
      end

      it 'returns false' do
        expect(controller.valid_user_session?).to be false
      end
    end

    context 'when absolute timeout has been reached (expires_at still in the future)' do
      before do
        session[:user_id] = {
          'value' => user.id,
          'expires_at' => 12.hours.from_now,
          'absolute_expires_at' => 1.second.ago
        }
      end

      it 'returns false' do
        expect(controller.valid_user_session?).to be false
      end
    end

    context 'without absolute_expires_at (legacy 30-day cookie)' do
      before do
        session[:user_id] = {
          'value' => user.id,
          'expires_at' => 30.days.from_now
        }
      end

      it 'returns false' do
        expect(controller.valid_user_session?).to be false
      end
    end

    context 'when session is valid (expires_at and absolute_expires_at in the future)' do
      before do
        session[:user_id] = {
          'value' => user.id,
          'expires_at' => 6.hours.from_now,
          'absolute_expires_at' => 24.hours.from_now
        }
      end

      it 'returns true' do
        expect(controller.valid_user_session?).to be true
      end
    end

    context 'when timestamps come back from the JSON cookie as ISO8601 strings' do
      before do
        session[:user_id] = {
          'value' => user.id,
          'expires_at' => 6.hours.from_now.iso8601(3),
          'absolute_expires_at' => 24.hours.from_now.iso8601(3)
        }
      end

      it 'returns true when both are in the future' do
        expect(controller.valid_user_session?).to be true
      end
    end

    context 'when expires_at string from the JSON cookie is in the past' do
      before do
        session[:user_id] = {
          'value' => user.id,
          'expires_at' => 1.second.ago.iso8601(3),
          'absolute_expires_at' => 24.hours.from_now.iso8601(3)
        }
      end

      it 'returns false' do
        expect(controller.valid_user_session?).to be false
      end
    end

    context 'when a timestamp is not a parseable date' do
      before do
        session[:user_id] = {
          'value' => user.id,
          'expires_at' => 'garbage',
          'absolute_expires_at' => 24.hours.from_now.iso8601(3)
        }
      end

      it 'returns false' do
        expect(controller.valid_user_session?).to be false
      end
    end
  end

  describe '#authenticate_user! session sliding' do
    context 'when session is valid' do
      before do
        session[:user_id] = {
          'value' => user.id,
          'expires_at' => 1.hour.from_now,
          'absolute_expires_at' => 24.hours.from_now
        }
      end

      it 'slides expires_at to approximately +12 h without touching absolute_expires_at' do
        freeze_time do
          absolute = session[:user_id]['absolute_expires_at']

          get :show

          expect(session[:user_id]['expires_at']).to be_within(1.minute).of(12.hours.from_now)
          expect(session[:user_id]['absolute_expires_at']).to eq(absolute)
        end
      end
    end

    context 'when expires_at + 12 h would exceed absolute_expires_at' do
      before do
        session[:user_id] = {
          'value' => user.id,
          'expires_at' => 1.hour.from_now,
          'absolute_expires_at' => 3.hours.from_now
        }
      end

      it 'caps expires_at at absolute_expires_at' do
        freeze_time do
          absolute = session[:user_id]['absolute_expires_at']

          get :show

          expect(session[:user_id]['expires_at']).to eq(absolute)
        end
      end
    end

    context 'when user is banned' do
      before do
        allow(controller).to receive(:current_user).and_return(
          instance_double(User, banned?: true)
        )
      end

      it 'raises BannedUserError without sliding the session' do
        original_expires_at = session[:user_id]['expires_at']

        expect { controller.authenticate_user! }.to raise_error(ApplicationController::BannedUserError)

        expect(session[:user_id]['expires_at']).to eq(original_expires_at)
      end
    end
  end
end
