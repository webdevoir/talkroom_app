class ArticlesController < ApplicationController
  def new
    @room = Room.find(params[:room_id])
    @article_messages = @room.messages
  end

  def create
    if params[:article_title] == ""
      @article = Article.create(title: "ARTICLE", like: 0)
    else
      @article = Article.create(title: params[:article_title], like: 0)
    end

    order = 1
    params[:messages].each do | message_id,judge |
      message = Message.find(message_id)
      if judge == "0"
        ArticleMessage.create(user_name: message.user_name, article_id: @article.id,
          content: message.content, filename: message.filename, order: order,
          attachment_data: message.attachment_data, created_at: message.created_at)
        order += 1
      end
    end
    redirect_to article_path(@article.id)
  end

  def index
    if params[:search] == nil || params[:search] == ''
      @articles = Article.all.order(like: "DESC")
      @article_heading = "ARTICLES"
    else
      words = params[:search].to_s.gsub(/(?:[[:space:]%_])+/, " ").split(" ")
      query = (["title LIKE ?"] * words.size).join(" AND ")
      @articles = Article.where(query, *words.map{|w| "%#{w}%"}).order(like: "DESC")
      @article_heading = "SEARCH RESULT"
    end
  end

  def show
    @article = Article.find(params[:id])
    @article_messages = @article.article_messages
  end

  def like
    @article = Article.find(params[:article_id])
    @article.like += 1
    @article.save
    redirect_to article_path(@article.id)
  end
end
