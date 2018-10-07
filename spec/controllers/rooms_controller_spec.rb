require 'rails_helper'

RSpec.describe RoomsController, type: :controller do

  context "show" do
    context "GET #show" do
      it "returns http success" do
        get :show
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
      end
      it "log_in" do
      end
    end
    context "search" do
      it "fulfill" do
      end
      it "empty" do
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
      end
      it "empty name" do
      end
    end
    context "room_tag" do
      it "create room_tag" do
      end
    end
  end

end
