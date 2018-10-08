require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  let!(:user) { FactoryBot.create(:user) }
  let!(:update_attributes) do
    { name: 'change name' }
  end
  before { log_in user }

  context "edit" do
    context "GET #edit" do
      it "returns http success" do
        get :edit, params: { id: user.id }
        expect(response).to have_http_status(:success)
      end
    end
  end
  context "update" do
    context "update user" do
      it "change user_name" do
        patch :update, params: { id: user.id, user: update_attributes }
        expect(response).to redirect_to rooms_path
      end
      it "error other user" do
        log_out user
        patch :update, params: { id: user.id, user: update_attributes }
        expect(response).to redirect_to root_path
      end
    end
  end

end
