require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do

  context "home" do
    context "GET #home" do
      it "returns http success" do
        get :home
        expect(response).to have_http_status(:success)
      end
    end
  end

end
