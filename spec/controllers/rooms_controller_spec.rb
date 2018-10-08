require 'rails_helper'

RSpec.describe RoomsController, type: :controller do

  let!(:user) { FactoryBot.create(:user) }
  let!(:room) { FactoryBot.create(:room) }
  before { log_in user }

  context "show" do
    context "GET #show" do
      it "returns http success" do
        get :show, params: { id: room.id }
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "index" do
    context "GET #index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
    context "user" do
      it "create and log_in" do
        log_out user
        expect { get :index }.to change{ User.count }.by(1)
      end
      it "log_in" do
        expect { get :index }.to_not change{ User.count }
      end
    end
    context "search" do
      it "fulfill" do
        post :index, params: { room: { search: "name" } }
        expect(response).to have_http_status(:success)
      end
      it "empty" do
        post :index, params: { room: { search: "" } }
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "new" do
    context "GET #new" do
      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "create" do
    context "change room_count when create room" do
      it "fulfill name" do
        expect {
          post :create, params: { name: ["new name"], room_tags: [""] }
        }.to change{ Room.count }.by(1)
      end
      it "empty name" do
        expect {
          post :create, params: { name: [""], room_tags: [""] }
        }.to change{ Room.count }.by(1)
      end
    end
    context "room_tag" do
      it "create room_tag" do
        expect {
          post :create, params: { name: ["new name"], room_tags: ["#tag#tag2"] }
        }.to change{ RoomTag.count }.by(2)
      end
    end
  end

end
