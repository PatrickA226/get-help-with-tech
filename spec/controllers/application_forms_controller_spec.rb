require 'rails_helper'

describe ApplicationFormsController, type: :controller do
  def sign_in_as(user)
    # TestSession doesn't do this automatically like a real session
    session[:session_id] = SecureRandom.uuid
    controller.send(:save_user_to_session!, user)
  end

  describe '#create' do
    let(:mobile_network) { create(:mobile_network) }
    let(:invalid_params) do
      {
        account_holder_name: '.',
      }
    end
    let(:valid_params) do
      {
        account_holder_name: 'Anne Account-Holder',
        device_phone_number: '01234 567890',
        mobile_network_id: mobile_network.id,
        can_access_hotspot: true,
        privacy_statement_sent_to_family: true,
        understands_how_pii_will_be_used: true,
      }
    end
    let(:params) { { application_form: valid_params } }
    let(:created_recipient) { Recipient.last }
    let(:the_request) { post :create, params: params }

    context 'with valid params and no existing user in session' do
      before do
        session.delete(:user)
        # TestSession doesn't create this automatically like a real session
        session[:session_id] = SecureRandom.uuid
      end

      it 'redirects to sign_in' do
        the_request
        expect(response).to redirect_to(sign_in_path)
      end

      it 'does not change the user_id in session' do
        expect { the_request }.not_to(change { session[:user_id] })
        expect(session[:user_id]).to be_nil
      end

      it 'does not create a Recipient' do
        expect { the_request }.not_to change(Recipient, :count)
      end
    end

    context 'with valid params and an existing user in session' do
      let(:user) { create(:local_authority_user) }

      before do
        sign_in_as user
      end

      it 'creates a Recipient with the right attributes' do
        the_request
        expect(created_recipient).to have_attributes(
          account_holder_name: 'Anne Account-Holder',
          device_phone_number: '01234 567890',
          mobile_network_id: mobile_network.id,
          status: Recipient.statuses[:requested],
        )
      end

      it 'creates a Recipient associated with the sessions user' do
        the_request
        expect(created_recipient.created_by_user_id).to eq(session[:user_id])
      end
    end

    context 'with invalid params and an existing user in session' do
      let(:user) { create(:local_authority_user) }
      let(:params) { { application_form: invalid_params } }
      let(:the_request) { post :create, params: params }

      before do
        sign_in_as user
      end

      it 'does not create a Recipient' do
        expect { post :create, params: params }.not_to change(Recipient, :count)
      end

      it 'responds with a 400 status code' do
        post :create, params: params
        expect(response.status).to eq(400)
      end
    end
  end
end