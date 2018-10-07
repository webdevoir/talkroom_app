require 'rails_helper'

RSpec.describe ChatRoomsController, type: :controller do

  context "show" do
    context "GET #show" do
      it "returns http success" do
        get :show
        expect(response).to have_http_status(:success)
      end
    end
  end
  context "index" do
    context "get index" do
      it "returns http success" do
      end
    end
    context "mach random chat_room" do
      it "enter other_chat_room" do
      end
      it "create chat_room" do
      end
    end
  end

end
