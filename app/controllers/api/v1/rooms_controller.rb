class Api::V1::RoomsController < ApplicationController

    def show
      @room = Room.find(params[:id])
      @messages = @room.messages
      render json: @messages
    end

    def index
      @rooms = Room.all
      render json: @rooms
    end

    def new
    end

    def create
    end

    def image
    end

  end
