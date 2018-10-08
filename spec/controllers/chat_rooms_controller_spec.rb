require 'rails_helper'

RSpec.describe ChatRoomsController, type: :controller do

  let!(:user) { FactoryBot.create(:user) }
  let!(:full_chat_room) { FactoryBot.create(:chat_room) }
  let!(:free_chat_room) { FactoryBot.create(:chat_room) }
  before { log_in user }

  context "index" do
    context "get index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status 302
      end
    end
    context "mach random chat_room" do
      it "enter other_chat_room" do
        free_chat_room.user2_id = nil
        free_chat_room.save
        expect{ get :index }.to_not change{ ChatRoom.count }
      end
      it "create chat_room" do
        expect{ get :index }.to change{ ChatRoom.count }.by(1)
      end
    end
  end

end
