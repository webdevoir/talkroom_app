require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  context "edit" do
    context "GET #edit" do
      it "returns http success" do
        get :edit
        expect(response).to have_http_status(:success)
      end
    end
  end
  context "update" do
    context "update user" do
      it "change user_name" do
      end
    end
  end

end
