class RoomsController < ApplicationController
  before_action :logged_in_user, only: [:show, :new, :create]

  def show
    @room = Room.find(params[:id])
    @messages = @room.messages
  end

  def index
    if logged_in? && User.exists?(id: current_user.id)
      @user = current_user
      @user.touch
      @user.save
    else
      new_user_setting
      log_in @user
    end
    room_search
    @room_tags = RoomTag.all
  end

  def new
  end

  def create
    room_tag_setting
    if @room_name.empty?
      room_setting
    else
      @room = Room.create(name: @room_name)
    end

    if @form_tags
      tags = @form_tags.split("#")
      tags.shift()
      tags.each do |tag|
        RoomTag.create(room_id: @room.id, name: tag)
      end
    end
    delete_room_user_inactive
    redirect_to room_path(@room.id)
  end

  def image
  end

  private

    def room_tag_setting
      @room_name = params[:name][0]
      @form_tags = params[:room_tags][0]
    end

    def room_setting
      @room = Room.create(name: "ROOM")
      @room.name = "ROOM#{@room.id}"
      @room.save
    end

    def room_search
      if params[:search].blank?
        @rooms = Room.all
        @room_heading = "ACTIVE ROOM"
      else
        words = params[:search].to_s.gsub(/(?:[[:space:]%_])+/, " ").split(" ")
        query = (["name LIKE ?"] * words.size).join(" AND ")
        @rooms_tag = RoomTag.where(query, *words.map{|w| "%#{w}%"})
        @rooms_id = []
        @rooms_tag.each do |room_tag|
          @rooms_id.push(room_tag.room_id)
        end
        @rooms = Room.where(query, *words.map{|w| "%#{w}%"}).or(Room.where(id: @rooms_id))
        @room_heading = "SEARCH RESULT"
      end
    end

    def delete_room_user_inactive
      last_month = Date.today.prev_month
      last_week = Date.today.prev_week
      delete_user = User.updated_at_between(nil, last_month)
      delete_room = Room.updated_at_between(nil, last_week)
      if delete_user.present?
        delete_user.destroy_all
      end
      if delete_room.present?
        delete_room.destroy_all
      end
    end

end
