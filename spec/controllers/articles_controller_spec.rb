require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  before { log_in user }

  context "new" do
    context "GET #new" do
      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "create" do
    context "change article_count when create" do
      it "fulfill title" do
        expect{
          post :create, params: { article: { article_title: "title" } }
        }.to change { Article.count }.by(1)
      end
      it "empty title" do
        expect{
          post :create, params: { article: { article_title: "" } }
        }.to change { Article.count }.by(1)
      end
    end
    context "change article_message_count when create" do
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
      end
      it "fulfill" do
      end
    end
  end

  context "show" do
    context "GET #show" do
      it "returns http success" do
        #make article, get id
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "like" do
    context "GET #like" do
      it "returns http success" do
        get :like
        expect(response).to have_http_status(:success)
      end
      it "like_count" do
      end
    end
  end

end
