class ArticlesController < ApplicationController
  def new
    @room = Room.find(params[:room_id])
    @messages = @room.messages
    @article = Article.create(title: @room.name)
    order = 1
    @messages.each do |message|
      ArticleMessage.create(user_name: message.user_name, article_id: @article.id,
       content: message.content, filename: message.filename, order: order,
       attachment_data: message.attachment_data, created_at: message.created_at)
       order += 1
    end
    @article_messages = @article.article_messages
  end

  def create
  end

  def index
  end

  def show
  end

  def like
  end
end
