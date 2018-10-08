require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do

  let!(:user) { FactoryBot.create(:user) }
  let!(:room) { FactoryBot.create(:room) }
  let!(:message) { FactoryBot.build(:message) }
  let!(:article) { FactoryBot.create(:article) }
  before { log_in user }

  context "new" do
    context "GET #new" do
      it "returns http success" do
        get :new, params: { room_id: room.id }
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "create" do
    context "change article_count when create" do
      it "fulfill title" do
        message_create(user,room)
        expect{
          post :create, params: { article_title: "title", messages: { "#{message.id}" => "0" } }
        }.to change { Article.count }.by(1)
      end
      it "empty title" do
        message_create(user,room)
        expect{
          post :create, params: { article_title: "", messages: { "#{message.id}" => "0" } }
        }.to change { Article.count }.by(1)
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
    context "search" do
      it "empty" do
        post :index, params: { room: { search: "" } }
        expect(response).to have_http_status(:success)
      end
      it "fulfill" do
        post :index, params: { room: { search: "title" } }
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "show" do
    context "GET #show" do
      it "returns http success" do
        get :show, params: { id: article.id }
        expect(response).to have_http_status(:success)
      end
    end
  end

  # context "like" do
  #   context "GET #like" do
  #     it "returns http success" do
  #       get :like, params: { article_id: article.id }
  #       expect(response).to have_http_status 302
  #     end
  #     it "like_count" do
  #       expect {
  #         get :like, params: { article_id: article.id }
  #       }.to change{ article.like }.by(1)
  #     end
  #   end
  # end

end
